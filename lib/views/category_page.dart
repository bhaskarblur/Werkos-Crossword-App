import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_word_search/api_services.dart';
import 'package:mobile_app_word_search/components/labels.dart';
import 'package:mobile_app_word_search/providers/category_provider.dart';
import 'package:mobile_app_word_search/providers/game_screen_provider.dart';
import 'package:mobile_app_word_search/utils/all_colors.dart';
import 'package:mobile_app_word_search/utils/buttons.dart';
import 'package:mobile_app_word_search/utils/custom_app_bar.dart';
import 'package:mobile_app_word_search/utils/font_size.dart';
import 'package:mobile_app_word_search/views/word_related_page.dart';
import 'package:mobile_app_word_search/widget/sahared_prefs.dart';
import 'package:mobile_app_word_search/widget/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../components/custom_dialogs.dart';
import '../providers/home_provider.dart';
import '../widget/navigator.dart';

class CategoryPage extends StatefulWidget {
  final String? type;
  const CategoryPage({Key? key, this.type}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final ApiServices _apiServices = ApiServices();

  @override
  void initState() {
    getData();

    super.initState();
  }

  getData() {
    final provider = Provider.of<CategoryProvider>(context, listen: false);

    Prefs.getPrefs('language').then((language) {
      _apiServices.post(
          context: context,
          endpoint: 'getcatstopics',
          body: {"language": language}).then((value) {
        provider.changeCategories(value['categoriesTopics']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AllColors.bg),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const PreferredSize(
            preferredSize: Size.fromHeight(70),
            child: CustomAppBar(isBack: true, isLang: true)),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Consumer<CategoryProvider>(builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Label(
                      text: AppLocalizations.of(context)!
                          .categories
                          .toUpperCase(),
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.h5),
                  const SizedBox(height: 20),
                  if (provider.categories != null)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: provider.categories.length,
                      separatorBuilder: (context, index) {
                        return gap(20);
                      },
                      itemBuilder: (context, index) {
                        bool isCategoryVisible = false;
                        return StatefulBuilder(builder: (context, st) {
                          return Column(
                            children: [
                              ShadowButton(
                                  onPressed: () {
                                    st(() {
                                      isCategoryVisible = !isCategoryVisible;
                                    });
                                  },
                                  title: provider.categories[index]
                                      ['categoryName'],
                                  fillColors: const [
                                    AllColors.semiLiteGreen,
                                    AllColors.shineGreen
                                  ]),
                              if (isCategoryVisible)
                                ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: provider
                                        .categories[index]['topicsList'].length,
                                    separatorBuilder: (context, i) {
                                      return gap(0);
                                    },
                                    itemBuilder: (context, i) {
                                      return TopicButton(
                                          onPressed: () {
                                            if (provider.categories[index]
                                                        ['topicsList'][i]
                                                    ['status'] ==
                                                'locked') {
                                              CustomDialog.showPurchaseDialog(
                                                  context: context);
                                            } else {
                                              final provider =
                                                  Provider.of<CategoryProvider>(
                                                      context,
                                                      listen: false);
                                              final gamePvider = Provider.of<
                                                      GameScreenProvider>(
                                                  context,
                                                  listen: false);

                                              if (widget.type == 'search') {
                                                gamePvider.changeGameType(
                                                    'searchbycategory');
                                                provider.changeSelectedCategory(
                                                    provider.categories[index]
                                                        ['topicsList'][i]);
                                                Nav.pop(context);
                                                final hprovider =
                                                    Provider.of<HomeProvider>(
                                                        context,
                                                        listen: false);
                                                hprovider
                                                    .changeSelectedIndex(4);
                                              } else {
                                                gamePvider.changeGameType(
                                                    'challengebycategory');
                                                provider.changeSelectedCategory(
                                                    provider.categories[index]
                                                        ['topicsList'][i]);
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            WordRelatedPage(
                                                                data: provider
                                                                            .categories[
                                                                        index][
                                                                    'topicsList'][i])));
                                              }
                                            }
                                          },
                                          lock: provider.categories[index]
                                              ['topicsList'][i]['status'],
                                          topicName: provider.categories[index]
                                              ['topicsList'][i]['topicsname']);
                                    }),
                            ],
                          );
                        });
                      },
                    ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class TopicButton extends StatelessWidget {
  const TopicButton({
    super.key,
    required this.onPressed,
    required this.topicName,
    required this.lock,
  });

  final VoidCallback onPressed;
  final String topicName;
  final String lock;

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
            child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lock == 'locked')
              const Icon(CupertinoIcons.lock_fill,
                  color: AllColors.liteGreen, size: 20),
            if (lock == 'locked') horGap(10),
            Label(
              text: topicName,
              fontSize: FontSize.p2,
            ),
          ],
        )),
      ),
    );
  }
}
