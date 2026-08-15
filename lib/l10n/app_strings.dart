import 'package:flutter/widgets.dart';
import '../models/order.dart';

/// Simple hand-written translations — no build_runner / codegen step,
/// so `flutter pub get` alone is enough to build. Add a new string by
/// adding one getter here and using it via AppStrings.of(context).
class AppStrings {
  final Locale locale;
  AppStrings(this.locale);

  static AppStrings of(BuildContext context) {
    return AppStrings(Localizations.localeOf(context));
  }

  bool get _ar => locale.languageCode == 'ar';

  // Login / Register
  String get welcomeBack => _ar ? 'أهلًا بعودتك' : 'Welcome Back';
  String get createAccount => _ar ? 'إنشاء حساب' : 'Create Account';
  String get fullName => _ar ? 'الاسم بالكامل' : 'Full name';
  String get phoneNumber => _ar ? 'رقم الهاتف' : 'Phone number';
  String get password => _ar ? 'كلمة المرور' : 'Password';
  String get pleaseEnterName => _ar ? 'من فضلك أدخل اسمك' : 'Please enter your name';
  String get pleaseEnterPhone => _ar ? 'من فضلك أدخل رقم الهاتف' : 'Please enter your phone number';
  String get pleaseEnterPassword => _ar ? 'من فضلك أدخل كلمة المرور' : 'Please enter your password';
  String get passwordMinLength => _ar ? 'يجب ألا تقل كلمة المرور عن 6 أحرف' : 'Password must be at least 6 characters';
  String get logIn => _ar ? 'تسجيل الدخول' : 'Log In';
  String get noAccountSignUp => _ar ? 'ليس لديك حساب؟ سجل الآن' : "Don't have an account? Sign up";

  // Orders list screen
  String hiName(String name) => _ar ? 'أهلًا، $name' : 'Hi, $name';
  String get logOut => _ar ? 'تسجيل الخروج' : 'Log out';
  String get newOrder => _ar ? 'طلب جديد' : 'New Order';
  String get noOrdersTitle => _ar ? 'لم تقم بإنشاء أي طلب بعد' : "You haven't placed any orders yet";
  String get noOrdersSubtitle => _ar ? 'أنشئ أول طلب لك للبدء.' : 'Create your first order to get started.';
  String get createFirstOrder => _ar ? 'أنشئ أول طلب لك' : 'Create your first order';
  String get retry => _ar ? 'إعادة المحاولة' : 'Retry';

  // Create order screen
  String get newOrderTitle => _ar ? 'طلب جديد' : 'New Order';
  String get whereToPickup => _ar ? 'من أين نستلم وإلى أين نوصل؟' : 'Where should we pick up and deliver?';
  String get pickupAddress => _ar ? 'عنوان الاستلام' : 'Pickup address';
  String get deliveryAddress => _ar ? 'عنوان التوصيل' : 'Delivery address';
  String get pleaseEnterPickup => _ar ? 'من فضلك أدخل عنوان الاستلام' : 'Please enter a pickup address';
  String get pleaseEnterDelivery => _ar ? 'من فضلك أدخل عنوان التوصيل' : 'Please enter a delivery address';
  String get placeOrder => _ar ? 'إرسال الطلب' : 'Place Order';

  // Order tracking screen
  String get trackOrder => _ar ? 'تتبع الطلب' : 'Track Order';
  String get refresh => _ar ? 'تحديث' : 'Refresh';
  String orderNumber(String id) => _ar ? 'طلب رقم #$id' : 'Order #$id';
  String get yourDriver => _ar ? 'السائق الخاص بك' : 'Your driver';
  String get assigned => _ar ? 'تم التعيين' : 'Assigned';
  String get callDriver => _ar ? 'اتصال بالسائق' : 'Call driver';
  String get pickup => _ar ? 'الاستلام' : 'Pickup';
  String get delivery => _ar ? 'التوصيل' : 'Delivery';
  String get noCoordinatesTitle => _ar ? 'لا توجد إحداثيات محفوظة' : 'No coordinates saved';

  // Status labels (shared with badges/stepper)
  String statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.created:
        return _ar ? 'تم استلام الطلب' : 'Order Placed';
      case OrderStatus.assigned:
        return _ar ? 'تم تعيين السائق' : 'Driver Assigned';
      case OrderStatus.pickedUp:
        return _ar ? 'تم الاستلام' : 'Picked Up';
      case OrderStatus.outForDelivery:
        return _ar ? 'في الطريق للتوصيل' : 'Out for Delivery';
      case OrderStatus.delivered:
        return _ar ? 'تم التوصيل' : 'Delivered';
      case OrderStatus.unknown:
        return _ar ? 'غير معروف' : 'Unknown';
    }
  }

  // Language toggle
  String get switchLanguage => _ar ? 'English' : 'العربية';

  // Branch selection screen
  String get chooseBranch => _ar ? 'اختر الفرع' : 'Choose a Branch';
  String get selectBranchPrompt => _ar ? 'اختر الفرع اللي هتطلب منه' : 'Select the branch you\'d like to order from';

  // Branch menu screen
  String get addedToCart => _ar ? 'تمت الإضافة للسلة' : 'Added to cart';
  String get chooseSize => _ar ? 'اختر الحجم' : 'Choose a size';
  String get add => _ar ? 'إضافة' : 'Add';
  String get viewCart => _ar ? 'عرض السلة' : 'View Cart';
  String get emptyMenu => _ar ? 'لا يوجد منيو متاح لهذا الفرع حاليًا' : 'No menu available for this branch right now';

  // Cart / checkout screen
  String get yourCart => _ar ? 'سلتك' : 'Your Cart';
  String get emptyCartTitle => _ar ? 'السلة فارغة' : 'Your cart is empty';
  String get emptyCartSubtitle => _ar ? 'أضف أصناف من المنيو للمتابعة' : 'Add items from the menu to continue';
  String get orderSummary => _ar ? 'ملخص الطلب' : 'Order Summary';
  String get total => _ar ? 'الإجمالي' : 'Total';
  String get deliveryDetails => _ar ? 'بيانات التوصيل' : 'Delivery Details';
  String get pickupFrom => _ar ? 'الاستلام من' : 'Pickup from';
  String get confirmOrder => _ar ? 'تأكيد الطلب' : 'Confirm Order';
  String currencyAed(String amount) => _ar ? '$amount د.إ' : 'AED $amount';
}
