import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_word_search/api_services.dart';
import 'package:mobile_app_word_search/components/labels.dart';
import 'package:mobile_app_word_search/providers/game_screen_provider.dart';
import 'package:mobile_app_word_search/providers/home_provider.dart';
import 'package:mobile_app_word_search/utils/all_colors.dart';
import 'package:mobile_app_word_search/utils/buttons.dart';
import 'package:mobile_app_word_search/utils/custom_app_bar.dart';
import 'package:mobile_app_word_search/utils/font_size.dart';
import 'package:mobile_app_word_search/views/category_page.dart';
import 'package:mobile_app_word_search/views/word_related_page.dart';
import 'package:mobile_app_word_search/widget/navigator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/custom_dialogs.dart';
import '../widget/sahared_prefs.dart';
import '../widget/widgets.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  final ApiServices _apiServices = ApiServices();

  final TextEditingController _playByCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(gradient: AllColors.bg),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: const PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: CustomAppBar(
                isBack: false,
                isLang: true,
              )),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Label(
                        text: AppLocalizations.of(context)!.play,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.h5),
                    const SizedBox(height: 20),
                    // Container(
                    //   height: 60,
                    //   padding: const EdgeInsets.only(left: 30, right: 20),
                    //   width: double.maxFinite,
                    //   decoration: BoxDecoration(
                    //       color: AllColors.liteDarkPurple,
                    //       borderRadius: BorderRadius.circular(50)),
                    //   child: Center(
                    //     child: TextFormField(
                    //         style: const TextStyle(
                    //             fontSize: FontSize.p2, color: AllColors.white),
                    //         decoration: InputDecoration(
                    //           focusedBorder: InputBorder.none,
                    //           enabledBorder: InputBorder.none,
                    //           hintText: AppLocalizations.of(context)!.search,
                    //           hintStyle: const TextStyle(
                    //               fontSize: FontSize.p2,
                    //               color: AllColors.white),
                    //           suffixIcon: const Icon(Icons.search_sharp,
                    //               color: AllColors.white),
                    //         ),
                    //         onSaved: (value) {}),
                    //   ),
                    // ),
                    SearchButton(
                        onPressed: () {
                          final gameScreenProvider =
                              Provider.of<GameScreenProvider>(context,
                                  listen: false);
                          gameScreenProvider.changeGameType('randomwordsearch');
                          final provider =
                              Provider.of<HomeProvider>(context, listen: false);
                          provider.changeSelectedIndex(4);
                        },
                        title:
                            AppLocalizations.of(context)!.random_word_search),
                    SearchButton(
                        onPressed: () {
                          Nav.push(context, const CategoryPage(type: 'search'));
                        },
                        title: AppLocalizations.of(context)!
                            .word_search_categories),
                    SearchButton(
                        onPressed: () {
                          print('Hellothere');
                          final gameScreenProvider =
                              Provider.of<GameScreenProvider>(context,
                                  listen: false);

                          Prefs.getToken().then((token) {
                            Prefs.getPrefs('loginId').then((loginId) {
                              Prefs.getPrefs('wordLimit').then((wordLimit) {
                                Prefs.getPrefs('gameLanguage').then((language) {
                                _apiServices.post(context: context, endpoint: 'randomusergenerated_crossword', body: {
                                  "accessToken": token,
                                  "userId": loginId,
                                  "type": 'challenge',
                                  'language':language,
                                }).then((value) {
                                  print('testgmae');
                                  print(value);
                                  if (value['gameDetails'] != null) {
                                    gameScreenProvider.changeGameData(value);
                                    gameScreenProvider.changeGameType('randomwordchallenge');
                                    gameScreenProvider.addToCorrectWordsIncorrectWordsFromAPI();
                                    if (value['gameDetails']['searchtype'] == 'search') {
                                      final provider =
                                      Provider.of<HomeProvider>(context, listen: false);
                                      provider.changeSelectedIndex(4);
                                    } else {
                                      Nav.push(context, WordRelatedPage(data: value));
                                    }
                                  } else {
                                    if (value['message'] != null) {
                                      dialog(context, value['message'], () {
                                        Nav.pop(context);
                                      });
                                    }
                                    else {
                                      CustomDialog.noGameAvailable(
                                          context: context);
                                    }
                                  }
                                });
    });
                              });
                            });
                          });

                          // gameScreenProvider
                          //     .changeGameType('randomwordchallenge');
                          // final provider =
                          //     Provider.of<HomeProvider>(context, listen: false);
                          // provider.changeSelectedIndex(4);
                        },
                        title: AppLocalizations.of(context)!.random_challenge),
                    SearchButton(
                        onPressed: () {
                          Nav.push(
                              context, const CategoryPage(type: 'category'));
                        },
                        title: AppLocalizations.of(context)!
                            .challenge_by_category),
                    const SizedBox(height: 12),
                    Label(
                        text:
                            AppLocalizations.of(context)!.play_by_entering_code,
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.h5),
                    const SizedBox(height: 20),
                    Container(
                        height: 60,
                        padding: const EdgeInsets.only(left: 30, right: 20),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: AllColors.liteDarkPurple,
                            borderRadius: BorderRadius.circular(50)),
                        child: Center(
                            child: TextFormField(
                                controller: _playByCodeController,
                                style: const TextStyle(
                                    fontSize: FontSize.p2,
                                    color: AllColors.white),
                                decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: AppLocalizations.of(context)!
                                        .enter_code,
                                    hintStyle: const TextStyle(
                                        fontSize: FontSize.p2,
                                        color: AllColors.white)),
                                onSaved: (value) {}))),
                    const SizedBox(height: 20),
                    ShadowButton(
                        onPressed: () {
                          final gameScreenProvider =
                              Provider.of<GameScreenProvider>(context,
                                  listen: false);
                          gameScreenProvider.changeGameType('gamewithcode');
                          // gameScreenProvider
                          //     .changeSearch(_playByCodeController.text);
                          getGameWithCode();
                        },
                        title: AppLocalizations.of(context)!
                            .play_with_entered_code,
                        fillColors: const [
                          AllColors.liteOrange,
                          AllColors.orange
                        ])
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  getGameWithCode() {
    final provider = Provider.of<GameScreenProvider>(context, listen: false);
    provider.reset();
    Prefs.getToken().then((token) {
      Prefs.getPrefs('loginId').then((loginId) {
        Prefs.getPrefs('wordLimit').then((wordLimit) {
          _apiServices.post(context: context, endpoint: 'getGameByCode', body: {
            "accessToken": token,
            "userId": loginId,
            "sharecode": _playByCodeController.text,
          }).then((value) {
            if (value['gameDetails'] != null) {
              provider.changeGameData(value);
              provider.changeGameType('gamewithcode');
              provider.addToCorrectWordsIncorrectWordsFromAPI();
              if (value['gameDetails']['searchtype'] == 'search') {
                final provider =
                    Provider.of<HomeProvider>(context, listen: false);
                provider.changeSelectedIndex(4);
              } else {
                Nav.push(context, WordRelatedPage(data: value));
              }
            } else {
              if (value['message'] != null) {
                CustomDialog.wrongCode(
                    context: context);
              }
              else {
                CustomDialog.wrongCode(
                    context: context);
              }
            }
          });
        });
      });
    });
  }
}

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
    required this.onPressed,
    required this.title,
  });
  final VoidCallback onPressed;
  final String title;
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minSize: 0,
      child: Container(
        height: 55,
        margin: const EdgeInsets.only(top: 12),
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: AllColors.liteDarkPurple,
            borderRadius: BorderRadius.circular(50)),
        child: Center(
            child: Label(
          text: title,
          fontSize: FontSize.p2,
        )),
      ),
    );
  }
}
