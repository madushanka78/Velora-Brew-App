import 'package:flutter/material.dart';

ValueNotifier<bool> isSinhala = ValueNotifier(false);

String t(String enText, String siText) {
  return isSinhala.value ? siText : enText;
}

ValueNotifier<int> globalPoints = ValueNotifier(350); 
List<Map<String, dynamic>> globalCart = [];

Map<String, dynamic> getMembershipLevel(int points) {
  if (points >= 1000) return {'name': 'Gold Member', 'icon': '🥇', 'color': Colors.amberAccent};
  if (points >= 500) return {'name': 'Silver Member', 'icon': '🥈', 'color': Colors.cyanAccent};
  return {'name': 'Bronze Member', 'icon': '🥉', 'color': Colors.brown};
}

List<Map<String, dynamic>> liveChatMessages = [
  {'text': 'Hello! Welcome to Velora Brew Support. How can we assist you today?', 'isBot': true},
];

final List<Map<String, dynamic>> fullMenu = [
  {'id': '1', 'nameEn': 'Signature Iced Coffee', 'nameSi': 'සිග්නේචර් අයිස් කෝපි', 'price': 450.0, 'cat': 'Drinks', 'image': 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?w=500'},
  {'id': '2', 'nameEn': 'Velora Special Espresso', 'nameSi': 'විශේෂ එස්ප්‍රෙසෝ', 'price': 350.0, 'cat': 'Drinks', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSwPSDVW6NHoz2jhKyPhIlBuSbgUsSydm5tMbkFb5BE9A&s'},
  {'id': '3', 'nameEn': 'Classic Cappuccino', 'nameSi': 'ක්ලැසික් කැපුචිනෝ', 'price': 550.0, 'cat': 'Drinks', 'image': 'https://t4.ftcdn.net/jpg/05/95/09/07/360_F_595090766_1wz5nknXYjZIiHHN2AkbNKCP5C0gzl7r.jpg'},
  {'id': '4', 'nameEn': 'Caramel Macchiato', 'nameSi': 'කැරමල් මැකියාටෝ', 'price': 750.0, 'cat': 'Drinks', 'image': 'https://emilylaurae.com/wp-content/uploads/2022/10/Caramel-macchiato-4.jpg'},
  {'id': '5', 'nameEn': 'Mocha Frappuccino', 'nameSi': 'මොකා ෆ්‍රැපුචිනෝ', 'price': 850.0, 'cat': 'Drinks', 'image': 'https://ucarecdn.com/b81e86d4-3522-438d-8b0b-1892bfee924a/-/format/auto/-/preview/3000x3000/-/quality/lighter/%E6%91%A9%E5%8D%A1%E6%98%9F%E5%86%B0%E4%B9%901.jpg'},
  {'id': '6', 'nameEn': 'Sri Lankan Milk Tea', 'nameSi': 'ශ්‍රී ලාංකික කිරි තේ', 'price': 150.0, 'cat': 'Drinks', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDCeH7sO7ssL-J6Kk-37cB4LN6RGj-MpHBRBdMZ2NbKA&s=10'},
  {'id': '7', 'nameEn': 'Hot Dark Chocolate', 'nameSi': 'උණුසුම් චොකලට්', 'price': 600.0, 'cat': 'Drinks', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpjNNzBTIxr9mvGs_7yFQjkWK85lQsydDZYLn2QILmqg&s=10'},
  {'id': '8', 'nameEn': 'Matcha Green Tea', 'nameSi': 'මච්චා ග්‍රීන් ටී', 'price': 700.0, 'cat': 'Drinks', 'image': 'https://static.vecteezy.com/system/resources/thumbnails/069/585/253/small/matcha-latte-art-with-green-tea-powder-on-wooden-tray-photo.jpg'},
  // මෙතන තිබ්බ Cold Brew එක අයින් කළා.
  {'id': '9', 'nameEn': 'Hot Coffee', 'nameSi': 'උණුසුම් කෝපි', 'price': 350.0, 'cat': 'Drinks', 'image': 'https://images.unsplash.com/photo-1611162458324-aae1eb4129a4?q=80&w=774&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'},
  {'id': '10', 'nameEn': 'Vanilla Bean Latte', 'nameSi': 'වැනිලා ලාටේ', 'price': 650.0, 'cat': 'Drinks', 'image': 'https://assets.surlatable.com/m/2ee217309ac4f8ba/72_dpi_webp-REC-506950_VanillaLatte-jpg'},
  {'id': '11', 'nameEn': 'Spicy Fish Roll', 'nameSi': 'මාළු රෝල්ස්', 'price': 180.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAdmzUCi1DhRbnLiQQItaF8A5qV4y2LRBeRx3YH5ZOd2UG1fXO8808yWHF&s=10'},
  {'id': '12', 'nameEn': 'Classic Egg Roll', 'nameSi': 'බිත්තර රෝල්ස්', 'price': 150.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSRZNlQORIJgbGPk1WtUIGyNAHYudB9hpj8S23gSxjiwqgYTrnUk3n8ns0&s=10'},
  {'id': '13', 'nameEn': 'Malu Paan (Fish Bun)', 'nameSi': 'මාළු පාන්', 'price': 160.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRpmEj7PLBdqRerRn6UcIyyOOUfi9O5RFujH_KauJoPSQu1YMFMdyUGfpU&s=10'},
  {'id': '14', 'nameEn': 'Chicken Patties', 'nameSi': 'චිකන් පැටිස්', 'price': 170.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZCAJ8sqrn06xrtkub5Y3sUn46v2l-yX3XkD7YxYJQmp4a3MzZoP8gYIE&s=10'},
  {'id': '15', 'nameEn': 'Vegetable Samosa', 'nameSi': 'එළවළු සමෝසා', 'price': 120.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQxIKpStVdIxV1y2vYw7h7awgLZVUmoiALrCMjsixQLZftWlpk-MyYGPhpp&s=10'},
  {'id': '16', 'nameEn': 'Seeni Sambol Bun', 'nameSi': 'සීනි සම්බෝල පාන්', 'price': 140.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTWa7qTy29re175WLwEdwwgx5xq_l44pL_z1DlSQqPX5sWJkQpSYZeQZYM&s=10'},
  {'id': '17', 'nameEn': 'Grilled Chicken Sandwich', 'nameSi': 'චිකන් සැන්ඩ්විච්', 'price': 450.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQDH0GmV2ttJIns9sl9EYg4UJOXPSPX7Qu415wq05JVYu6rnKBe_lyyPjU&s=10'},
  {'id': '18', 'nameEn': 'Melted Cheese Toast', 'nameSi': 'චීස් ටෝස්ට්', 'price': 350.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhj6Q8ZiJLeOcDn0Xwi4NsBvDRwKWwO9IfwxPFlJ00Fw&s=10'},
  {'id': '19', 'nameEn': 'Garlic Bread Sticks', 'nameSi': 'ගාර්ලික් බ්‍රෙඩ්', 'price': 300.0, 'cat': 'Food', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT3mOYBlAXRN4kePl9EVLC2qDh037M9MO1g-QivS_WGIdfHeJdTChzh7LP7&s=10'},
  {'id': '20', 'nameEn': 'Crispy Potato Fries', 'nameSi': 'අල පෙති (ෆ්‍රයිස්)', 'price': 400.0, 'cat': 'Food', 'image': 'https://images.immediate.co.uk/production/volatile/sites/30/2024/07/French-fries-a084f8f.jpg'},
  {'id': '21', 'nameEn': 'Dark Chocolate Fudge', 'nameSi': 'චොකලට් ෆජ් කේක්', 'price': 650.0, 'cat': 'Dessert', 'image': 'https://flavorthemoments.com/wp-content/uploads/2024/11/dark-chocolate-fudge-1.jpg'},
  {'id': '22', 'nameEn': 'New York Cheesecake', 'nameSi': 'චීස් කේක්', 'price': 850.0, 'cat': 'Dessert', 'image': 'https://prettysimplesweet.com/wp-content/uploads/2018/10/New-York-Style-Cheesecake.jpg'},
  {'id': '23', 'nameEn': 'Blueberry Muffin', 'nameSi': 'බ්ලූබෙරි මෆින්', 'price': 450.0, 'cat': 'Dessert', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTKB0S4eYcUFOqcvtFw3WDd2xg5px9geTRlzi6piDYgjpRbObxSXvQqgzrw&s=10'},
  {'id': '24', 'nameEn': 'Butter Croissant', 'nameSi': 'බටර් ක්‍රොයිසන්ට්', 'price': 400.0, 'cat': 'Dessert', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSirFrM9HH9tyqWudiNladSK9AcoUhPhQLbtXeqBdJOFq5Othz-yJlQIbA&s=10'},
  {'id': '25', 'nameEn': 'Sri Lankan Watalappam', 'nameSi': 'ශ්‍රී ලාංකික වටලප්පන්', 'price': 350.0, 'cat': 'Dessert', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSo5olV2KGCzpOfiHLS2C3fcj8Q56tRj95gYG7YM4hy6g&s=10'},
  {'id': '26', 'nameEn': 'Lemon Juice', 'nameSi': 'ලෙමන් යුෂ', 'price': 300.0, 'cat': 'Drinks', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqcRsXt2T_Al-WBdKFCHw08mO3sX41nkUyHsrh80YoN481xCZbIxGBCfc&s=10'},
  {'id': '27', 'nameEn': 'Orange Juice', 'nameSi': 'දොඩම් යුෂ', 'price': 300.0, 'cat': 'Drinks', 'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRd5AyUi8pJOLCYrLoFBlEINGdH9CnCVA-bSjQjj-Dr_yWKcEqcqPEJETdS&s=10'},
  {'id': '28', 'nameEn': 'Watermelon Juice', 'nameSi': 'පැණි කොමඩු යුෂ', 'price': 300.0, 'cat': 'Drinks', 'image': 'https://thedizzycook.com/wp-content/uploads/2025/07/Watermelon-Juice-Main-2.jpg'},
  {'id': '29', 'nameEn': 'Avocado Juice', 'nameSi': 'අලිගැටපේර යුෂ', 'price': 300.0, 'cat': 'Drinks', 'image': 'https://joyfoodsunshine.com/wp-content/uploads/2022/05/banana-avocado-smoothie-recipe-5-500x500.jpg'},
  {'id': '30', 'nameEn': 'Mango Juice', 'nameSi': 'අඹ යුෂ', 'price': 300.0, 'cat': 'Drinks', 'image': 'https://www.cubesnjuliennes.com/wp-content/uploads/2022/07/Mango-Juice-Recipe.jpg'},
];