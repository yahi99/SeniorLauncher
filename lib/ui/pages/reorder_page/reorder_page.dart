import 'package:senior_launcher/constants/edit_mode.dart';
import 'package:senior_launcher/models/app_model.dart';
import 'package:senior_launcher/models/contact_model.dart';
import 'package:senior_launcher/models/edit_model.dart';
import 'package:senior_launcher/models/item.dart';
import 'package:senior_launcher/generated/l10n.dart';
import 'package:senior_launcher/ui/common/buttons.dart';
import 'package:senior_launcher/ui/common/info_action_widget.dart';
import 'package:senior_launcher/ui/pages/reorder_page/reorder_widget.dart';
import 'package:senior_launcher/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReorderPage extends StatelessWidget {
  final EditMode editMode;

  const ReorderPage(this.editMode);

  @override
  Widget build(BuildContext context) {
    List<Item> _favItems = [];

    if (editMode == EditMode.apps) {
      _favItems = Provider.of<AppModel>(context).favApps;
    } else {
      _favItems = Provider.of<ContactModel>(context).favContacts;
    }

    void backToHome() {
      Navigator.pop(context);
    }

    void saveFavItems(List<String> newFavItems) {
      if (editMode == EditMode.apps) {
        Provider.of<AppModel>(context, listen: false).saveFavApps(newFavItems);
      } else {
        Provider.of<ContactModel>(context, listen: false)
            .saveFavContacts(newFavItems);
      }
    }

    return ChangeNotifierProvider(
      create: (_) => EditModel(favItems: _favItems),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Flexible(
                child: Consumer<EditModel>(
                  builder: (_, editModel, __) => Column(
                    children: <Widget>[
                      if (editModel.sortedItems.isNotEmpty) ...[
                        Expanded(
                          child: ReorderWidget(editModel,
                              showId:
                                  editMode == EditMode.contacts ? true : false),
                        ),
                      ] else ...[
                        InfoActionWidget.close(
                          message: S.of(context).msgNoData,
                          buttonLabel: S.of(context).btnBackToHome,
                          buttonOnClickAction: backToHome,
                        )
                      ]
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: PrimaryButton(S.of(context).btnBackToHome, backToHome),
              ),
            ],
          ),
        ),
        floatingActionButton: Consumer<EditModel>(
          builder: (context, editModel, _) {
            if (editModel.isListModified) {
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: Values.fabSafeBottomPadding),
                child: FloatingActionButton(
                  child: const Icon(Icons.check),
                  backgroundColor: Colors.redAccent[100],
                  onPressed: () {
                    saveFavItems(editModel.getFavIds());
                    Navigator.pop(context);
                  },
                ),
              );
            } else {
              return Container(height: 0, width: 0);
            }
          },
        ),
      ),
    );
  }
}
