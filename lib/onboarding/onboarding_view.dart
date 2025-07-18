import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:votex/Components/home.dart';
import 'package:votex/login/signup/loginpage.dart';

import 'package:votex/onboarding/onbording_item.dart';


class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnbordingItem();
  final pageController = PageController();

  bool islastpage = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
        child: islastpage? getStarted() : Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            //Skip button
            TextButton(
              onPressed: () => pageController.jumpToPage(controller.items.length-1), 
              child: const Text("Skip")),
        
            //Indicators
            SmoothPageIndicator(
              controller: pageController, 
              count: controller.items.length,
              onDotClicked: (index) => pageController.animateToPage(index, 
              duration: Duration(milliseconds: 600), curve: Curves.easeIn),
              //const before WormEffect
              effect:  WormEffect(
                dotHeight: 18,
                dotWidth: 18,
                spacing: 20,
                activeDotColor: Colors.pink.shade300
        
              ),
            ),
              
        
             // Next button
            TextButton(
              onPressed: () => pageController.nextPage(
                duration: const Duration(milliseconds: 600), curve: Curves.easeIn), 
              child: const Text("Next")),
          ],
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        child: PageView.builder(
          onPageChanged: (index)=> setState(()=> islastpage = controller.items.length-1 == index),
          itemCount: controller.items.length,
          controller: pageController,
          itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(controller.items[index].image),
              const SizedBox(height: 20),
              Text(controller.items[index].title,
               style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold),),
              const SizedBox(height: 20),
              Text(controller.items[index].description,
               style: const TextStyle(color: Colors.blueGrey, fontSize: 18 ), textAlign: TextAlign.center),
            ],
          );
        },),
      ),
    );
  }
 
  //Get startes button

  Widget getStarted(){
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.pink.shade200
      ),
      width: MediaQuery.of(context).size.width*.9,
      height: 54,
      child: TextButton(
        onPressed: ()async{
          final pres = await SharedPreferences.getInstance();
          pres.setBool("onboarding", true);

          if(!mounted)return;
          // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));

        }, 
        child: const Text("Let's Start", style: TextStyle(color: Colors.white,fontSize: 18))),
    );

  }
}