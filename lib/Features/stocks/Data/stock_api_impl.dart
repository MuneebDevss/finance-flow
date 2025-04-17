import 'dart:async';
import 'package:finance/Features/stocks/domain/stock_repo.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

final String apiKey = 'E7VGEB1DL8GTREMX'; // Replace with your API key
final String apiKey2 = 'QOQAIENNIT4JT7RK';

// class StockPriceService implements PriceFetchService {
//   @override
//   Future<double> fetchPrice(String symbol) async {
//     try {
//       print('Attempting to fetch price for symbol: $symbol');

//       final response = await http.get(Uri.parse(
//           'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey2'));

//       if (response.statusCode != 200) {
//         _showErrorSnackbar('HTTP error: Status code ${response.statusCode}');
//         return 0.0;
//       }

//       final data = json.decode(response.body);

//       // Check for rate limiting
//       if (data.containsKey('Information') &&
//           data['Information'].toString().contains('API rate limit')) {
//         _showErrorSnackbar('API rate limit reached. Try again later.');
//         return 0.0;
//       }

//       // Continue with normal processing
//       if (!data.containsKey('Global Quote')) {
//         _showErrorSnackbar('Unexpected response format from API');
//         return 0.0;
//       }

//       final globalQuote = data['Global Quote'];
//       if (!globalQuote.containsKey('05. price')) {
//         _showErrorSnackbar('Price data not found for $symbol');
//         return 0.0;
//       }

//       return double.parse(globalQuote['05. price']);
//     } catch (e) {
//       print('Error fetching stock price for $symbol: $e');
//       _showErrorSnackbar('Failed to fetch price for $symbol');
//       print('Attempting to fetch price for symbol: $symbol');

//       final response = await http.get(Uri.parse(
//           'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$apiKey'));

//       if (response.statusCode != 200) {
//         _showErrorSnackbar('HTTP error: Status code ${response.statusCode}');
//         return 0.0;
//       }

//       final data = json.decode(response.body);

//       // Check for rate limiting
//       if (data.containsKey('Information') &&
//           data['Information'].toString().contains('API rate limit')) {
//         _showErrorSnackbar('API rate limit reached. Try again later.');
//         return 0.0;
//       }

//       // Continue with normal processing
//       if (!data.containsKey('Global Quote')) {
//         _showErrorSnackbar('Unexpected response format from API');
//         return 0.0;
//       }

//       final globalQuote = data['Global Quote'];
//       if (!globalQuote.containsKey('05. price')) {
//         _showErrorSnackbar('Price data not found for $symbol');
//         return 0.0;
//       }
//       return 0.0;
//     }
//   }

// // You'll need to implement this method to show the snackbar
//   void _showErrorSnackbar(String message) {
//     // If you're in a StatefulWidget with a ScaffoldMessengerState
//     ScaffoldMessenger.of(Get.context!).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }
// }

class CryptoPriceService implements PriceFetchService {
  final String apiKey =
      'CG-E5F4nnGKTGkRG5artWU914LJ'; // Your CoinGecko Pro API key

  @override
  Future<double> fetchPrice(String symbol) async {
    try {
      print('Attempting to fetch crypto price for: $symbol');

      final response = await http.get(
          Uri.parse(
              'https://api.coingecko.com/api/v3/simple/price?ids=$symbol&vs_currencies=usd'),
          headers: {'accept': 'application/json', 'x-cg-api-key': apiKey});

      if (response.statusCode != 200) {
        print(
            'HTTP error: Status code ${response.statusCode}, Body: ${response.body}');
        print('HTTP error: Status code ${response.statusCode}');
        return 0.0;
      }

      final data = json.decode(response.body);
      print('Response data: $data');

      // if (!data.containsKey(symbol.toLowerCase())) {
      //   _showSnackbar('Crypto symbol "$symbol" not found');
      //   return 0.0;
      // }

      // if (!data[symbol.toLowerCase()].containsKey('usd')) {
      //   _showSnackbar('USD price not available for $symbol');
      //   return 0.0;
      // }

      return data[symbol.toLowerCase()]['usd'].toDouble();
    } catch (e) {
      print('Error fetching crypto price for $symbol: $e');
      _showSnackbar('Failed to fetch price for $symbol');
      return 0.0;
    }
  }

  void _showSnackbar(String message) {
    // Your snackbar implementation here
    Get.snackbar('SNACKBAR: $message', message);
  }
}
