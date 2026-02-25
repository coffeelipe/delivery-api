import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressService {
  static const String _baseUrl = 'https://viacep.com.br/ws';

  Future<Map<String, dynamic>?> fetchAddressByCep(String cep) async {
    try {
      // Remove non-numeric characters
      final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

      if (cleanCep.length != 8) {
        return null;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/$cleanCep/json/'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // ViaCEP returns {"erro": true} when CEP is not found
        if (data['erro'] == true) {
          return null;
        }

        return {
          'street': data['logradouro'] ?? '',
          'neighborhood': data['bairro'] ?? '',
          'city': data['localidade'] ?? '',
          'state': data['uf'] ?? '',
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
