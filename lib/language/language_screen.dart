import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:invoice_management/ui/invoice_screen.dart';
import 'package:invoice_management/utils/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  bool isChecked = false;
  int selectedIndex = 0;
  List languages = [
    {
      'name': 'English',
      'image':
          'https://t2.gstatic.com/licensed-image?q=tbn:ANd9GcQVhwOar0FyOb_mmItcTAQFv1O4k8S_ZUEAI45O7dYC2rXRUWD-nWJwOQWJS2va8krELcDtY0JEVdQabkDkEdo',
    },
    {
      'name': 'Bangla',
      'image':
          'https://cdn.britannica.com/67/6267-004-10A21DF0/Flag-Bangladesh.jpg',
    },
    {
      'name': 'Arabic',
      'image':
          'https://cdn.britannica.com/79/5779-004-DC479508/Flag-Saudi-Arabia.jpg',
    }
  ];

  @override
  initState() {
    getSelectedLanguage();
    super.initState();
  }

  getSelectedLanguage() async {
    var selectedLanguage =
        await SPUtill.getSelectLanguage(SPUtill.keySelectLanguage);
    if (kDebugMode) {
      print("selectedLanguage Local: $selectedLanguage");
    }
    if (selectedLanguage != null) {
      setState(() {
        selectedIndex = selectedLanguage;
        if (kDebugMode) {
          print("selectedIndex sssss: $selectedLanguage");
        }
      });
    } else {
      setState(() {
        selectedIndex = 0;
        if (kDebugMode) {
          print("selectedIndex deflt: $selectedIndex");
        }
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const InvoicesScreen()),
                    (Route<dynamic> route) => true);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
                child: Icon(Icons.arrow_back),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  Lottie.asset('assets/images/language_lottie.json',
                      height: 100, width: 100),
                  const SizedBox(
                    height: 25,
                  ),
                  Text('choose_your_preferred_language'.tr(),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54))
                      .tr(),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "please_select_your_language".tr(),
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ).tr(),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: languages.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                              SPUtill.setLanguageIntValue(
                                  SPUtill.keySelectLanguage, selectedIndex);
                              if (kDebugMode) {
                                print(selectedIndex);
                              }
                              if (selectedIndex == 0) {
                                context.setLocale(const Locale('en', 'US'));
                              } else if (selectedIndex == 1) {
                                context.setLocale(const Locale('bn', 'BN'));
                              } else if (selectedIndex == 2) {
                                context.setLocale(const Locale('ar', 'AR'));
                              }
                              getSelectedLanguage();
                            });
                          },
                          child: Row(
                            children: [
                              ClipOval(
                                child: CachedNetworkImage(
                                  height: 30,
                                  width: 30,
                                  fit: BoxFit.cover,
                                  imageUrl: "${languages[index]['image']}",
                                  placeholder: (context, url) => const Center(
                                    child: Icon(Icons.error),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Text(
                                languages[index]['name'] ?? "",
                                style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              SizedBox(
                                height: selectedIndex == index ? 30 : 0,
                                width: selectedIndex == index ? 30 : 0,
                                child: Icon(
                                  Icons.check,
                                  size: selectedIndex == index ? 24 : 0,
                                  color: Colors.blue.withOpacity(
                                      selectedIndex == index ? 0.85 : 0),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
