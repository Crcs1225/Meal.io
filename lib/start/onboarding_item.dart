import 'onboarding_info.dart';

class OnboardingItems {
  List<OnboardingInfo> items = [
    OnboardingInfo(
        title: "Browse Recipe",
        descriptions:
            "Explore a vast collection of recipes tailored to your taste and preferences.",
        image: "assets/browse.json"),
    OnboardingInfo(
        title: "Scan Ingrediens",
        descriptions:
            "Quickly scan your ingredients to find matching recipes and nutritional information.",
        image: "assets/scan.json"),
    OnboardingInfo(
        title: "Recommendation",
        descriptions:
            "Get personalized recipe recommendations based on your dietary needs and preferences.",
        image: "assets/recommend.json"),
    OnboardingInfo(
        title: "Cook",
        descriptions:
            "Follow step-by-step instructions to create delicious meals with ease.",
        image: "assets/last.json"),
  ];
}
