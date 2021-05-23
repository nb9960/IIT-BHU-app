import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:iit_app/data/internet_connection_interceptor.dart';
import 'package:iit_app/model/built_post.dart';
import 'package:iit_app/model/appConstants.dart';
import 'package:iit_app/model/colorConstants.dart';
import 'package:iit_app/model/deprecatedWidgetsStyle.dart';
import 'package:iit_app/model/workshopCreator.dart';
import 'package:iit_app/ui/club_council_entity_common/club_council_entity_widgets.dart';
import 'package:iit_app/ui/dialogBoxes.dart';
import 'package:iit_app/ui/workshopDetail_custom_widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class WorkshopDetailPage extends StatefulWidget {
  final int workshopId;
  final BuiltWorkshopSummaryPost workshop;
  final bool isPast;

  const WorkshopDetailPage(this.workshopId,
      {this.workshop, this.isPast = false});

  @override
  _WorkshopDetailPage createState() => _WorkshopDetailPage();
}

class _WorkshopDetailPage extends State<WorkshopDetailPage> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      new GlobalKey<ScaffoldMessengerState>();
  final PanelController _panelController = PanelController();
  BuiltWorkshopSummaryPost workshopSummary;

  BuiltWorkshopDetailPost _workshop;
  int is_interested;

  @override
  void initState() {
    this.workshopSummary = widget.workshop;
    fetchWorkshopDetails();
    super.initState();
  }

  showSuccessfulDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Successful!"),
          content: Text("Succesfully deleted!"),
        );
      },
    );
  }

  Future showUnsuccessfulDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Unsuccessful :("),
          content: Text("Please try again."),
          actions: <Widget>[
            TextButton(
              style: flatButtonStyle,
              child: Text("Ok."),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> confirmDeleteDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete resource"),
          content: Text("Are you sure to remove this resource?"),
          actions: <Widget>[
            TextButton(
              style: flatButtonStyle,
              child: Text("No. Take Me Back."),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: flatButtonStyle,
              child: Text("Yup!"),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  Future _reload() async {
    await fetchWorkshopDetails();
  }

  Future fetchWorkshopDetails() async {
    await AppConstants.service
        .getWorkshopDetailsPost(widget.workshopId, AppConstants.djangoToken)
        .then((snapshots) {
      _workshop = snapshots.body;
      if (_workshop.is_interested != null) {
        is_interested = _workshop.is_interested ? 1 : -1;
      } else {
        is_interested = -1;
      }

      workshopSummary = workshopSummary == null
          ? BuiltWorkshopSummaryPost((b) => b
            ..id = widget.workshopId
            ..club = _workshop.club?.toBuilder()
            ..entity = _workshop.entity?.toBuilder()
            ..title = _workshop.title
            ..date = _workshop.date
            ..is_workshop = _workshop.is_workshop
            ..time = _workshop.time
            ..tags = _workshop.tags?.toBuilder())
          : workshopSummary.rebuild((builder) => builder
            ..title = _workshop.title
            ..date = _workshop.date
            ..time = _workshop.time
            ..tags = _workshop.tags?.toBuilder());
    }).catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
        return;
      }
      print("Error in fetching workshop: ${onError.toString()}");
    });

    if (!this.mounted) return;
    setState(() {});
  }

  void deleteWorkshop() async {
    bool isConfirmed = await CreatePageDialogBoxes.confirmDialog(
        context: context, title: 'Delete', action: 'Delete');
    if (isConfirmed == true) {
      AppConstants.service
          .removeWorkshop(widget.workshopId, AppConstants.djangoToken)
          .then((snapshot) async {
        await WorkshopCreater.deleteImageFromFirestore(_workshop.image_url);

        print("status of deleting workshop: ${snapshot.statusCode}");
        await showSuccessfulDialog();
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', ModalRoute.withName('/root'));
      }).catchError((onError) async {
        if (onError is InternetConnectionException) {
          AppConstants.internetErrorFlushBar.showFlushbar(context);
          return;
        }
        print("Error in deleting: ${onError.toString()}");
        await CreatePageDialogBoxes.showUnsuccessfulDialog(context: context);
      });
    }
    if (this.mounted) setState(() {});
  }

  void deleteResource(int id) async {
    bool _deleteAction = await confirmDeleteDialog();
    if (_deleteAction != true) return;

    bool _isDeleted = false;
    await AppConstants.service
        .deleteWorkshopResources(id, AppConstants.djangoToken)
        .then((snapshot) async {
      print("status of deleting resource ${snapshot.statusCode}");
      _isDeleted = true;
    }).catchError((error) {
      if (error is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
        return;
      }
      print("Error in deleting: ${error.toString()}");
      showUnsuccessfulDialog();
    });

    if (_isDeleted) {
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                content: Text("Resource deleted"),
                actions: <Widget>[
                  TextButton(
                    style: flatButtonStyle,
                    child: Text("yay"),
                    onPressed: () => Navigator.pop(context),
                  )
                ]);
          });
      _reload();
    }

    setState(() {});
  }

  void updateButton() async {
    is_interested = 0;
    setState(() {});
    await AppConstants.service
        .toggleInterestedWorkshop(widget.workshopId, AppConstants.djangoToken)
        .then((snapshot) {
      print("status of toggle workshop: ${snapshot.statusCode}");
      if (snapshot.isSuccessful) {
        is_interested = (_workshop.is_interested ? 1 : -1) * -1;
        int _newInterestedUser = is_interested == 1 ? 1 : -1;

        if (_newInterestedUser == 1) {
          FirebaseMessaging.instance.subscribeToTopic('W_${_workshop.id}');
        } else {
          FirebaseMessaging.instance.unsubscribeFromTopic('W_${_workshop.id}');
        }

        _workshop.rebuild((b) => b
          ..interested_users = _workshop.interested_users + _newInterestedUser);
      }
    }).catchError((onError) {
      if (onError is InternetConnectionException) {
        AppConstants.internetErrorFlushBar.showFlushbar(context);
        return;
      }
      print("Error in toggling: ${onError.toString()}");
    });
    setState(() {});
    _reload();
  }

  Future<bool> _willPopCallback() async {
    if (_panelController.isPanelOpen) {
      _panelController.close();
      return false;
    } else {
      return true;
    }
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(24.0),
    topRight: Radius.circular(24.0),
  );

  @override
  Widget build(BuildContext context) {
    final workshopDetailCustomWidgets = WorkshopDetailCustomWidgets(
        workshopDetail: _workshop,
        workshopSummary: workshopSummary,
        context: context,
        isPast: widget.isPast,
        is_interested: is_interested,
        scaffoldMessengerKey: _scaffoldMessengerKey,
        updateButton: updateButton,
        reload: _reload,
        deleteWorkshop: deleteWorkshop,
        deleteResource: deleteResource);

    return SafeArea(
        minimum: const EdgeInsets.all(2.0),
        child: this.workshopSummary == null
            ? Center(child: CircularProgressIndicator())
            : WillPopScope(
                onWillPop: _willPopCallback,
                child: RefreshIndicator(
                  onRefresh: () async => _reload(),
                  child: Scaffold(
                    key: _scaffoldMessengerKey,
                    backgroundColor: ColorConstants.backgroundThemeColor,
                    body: SlidingUpPanel(
                      controller: _panelController,
                      body: workshopDetailCustomWidgets.getPanelBackground(),
                      borderRadius: radius,
                      backdropEnabled: true,
                      parallaxEnabled: true,
                      collapsed: Container(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                        ),
                      ),
                      minHeight: ClubCouncilAndEntityWidgets.getMinPanelHeight(
                          context),
                      maxHeight: ClubCouncilAndEntityWidgets.getMaxPanelHeight(
                          context),
                      header:
                          workshopDetailCustomWidgets.getPanelHeader(context),
                      panelBuilder: (ScrollController sc) =>
                          workshopDetailCustomWidgets.getPanel(sc: sc),
                    ),
                  ),
                ),
              ));
  }
}
