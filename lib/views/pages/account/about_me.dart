import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:note_taker/views/widgets/rounded_icon_button.dart';

import '../../../components/components.dart';

class AboutMe extends StatelessWidget {
  const AboutMe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'About Me',
          style: TextStyle(color: kTextColor),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, color: kIconColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            const CircleAvatar(
              radius: 70.0,
              backgroundColor: kPrimaryColor,
              backgroundImage: AssetImage(
                kMeImg,
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: "I'm ", style: TextStyle(fontSize: 25)),
                  TextSpan(
                      text: 'Ye Lwin Oo',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                          color: kTextColor)),
                ],
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(flex: 5,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text:
                          "${"\t" * 8}I have been working as a mobile developer using Flutter for 2 years and "
                          "highly passionate about Artificial Intelligence and Software Engineering. "
                          "Ultimately, I love to solve programming challenges as a hobby. "
                          "This is one of my ",
                      style: const TextStyle(fontSize: 20),
                    ),
                    const TextSpan(
                        text: "ShowCase Projects",
                        style: TextStyle(
                            fontSize: 22.0,
                            color: kIconColor,
                            fontWeight: FontWeight.bold))
                  ]),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0,left: 50,right: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    iconSize: 60.0,
                    onPressed: () async{
                      const url = 'https://www.linkedin.com/in/ye-lwin-oo-ucsm/';
                      await launch(url);
                    },
                    icon: Card(
                      elevation: 10.0,
                      shadowColor: Theme.of(context).scaffoldBackgroundColor,
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.asset(
                          kLinkedInImg,
                          fit: BoxFit.cover,
                          scale: 0.5,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 60.0,
                    onPressed: () async{
                      const url = 'https://github.com/YeLwinOo-Steve';
                      await launch(url);
                    },
                    icon: Card(
                      elevation: 10.0,
                      shadowColor: Theme.of(context).scaffoldBackgroundColor,
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.asset(
                          kGithubImg,
                          fit: BoxFit.cover,
                          scale: 0.5,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 60.0,
                    onPressed: () async{
                      const url = 'https://www.facebook.com/ye.lwin.oo.someone';
                      await launch(url);
                    },
                    icon: Card(
                      elevation: 10.0,
                      shadowColor: Theme.of(context).scaffoldBackgroundColor,
                      color: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Image.asset(
                          kFacebookImg,
                          fit: BoxFit.cover,
                          scale: 0.5,
                        ),
                      ),
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
