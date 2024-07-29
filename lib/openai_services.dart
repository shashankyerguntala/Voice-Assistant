import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:project_1/secrets.dart';

class OpenAIService {
  final List<Map<String, String>> messages = [];
  Future<String> isPromptGptOrDalle(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'content-Type': 'applcation/json',
          'Authorization': 'Bearer $openApiKey'
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": [
              {
                "role": "user",
                "content":
                    "does this message want to generate an ai picture or something similar "
              }
            ]
          },
        ),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices']['0']['message']['content'];
        content = content.trim();

        switch (content) {
          case 'yes':
          case 'Yes':
          case 'yes.':
          case 'Yes.':
            final response = await dallE(prompt);
            return response;
          default:
            final response = await chatGpt(prompt);
            return response;
        }
      }
    } catch (e) {
      e.toString();
    }
    return 'An internal error Occured / the Api Key Expired Renew It';
  }

  Future<String> chatGpt(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'content-Type': 'applcation/json',
          'Authorization': 'Bearer $openApiKey'
        },
        body: jsonEncode(
          {
            "model": "gpt-3.5-turbo",
            "messages": messages,
          },
        ),
      );
      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices']['0']['message']['content'];
        content = content.trim();

        messages.add({'role': 'assistant', 'content': content});
        return content;
      }
    } catch (e) {
      e.toString();
    }
    return 'An internal error Occured / the Api Key Expired Renew It';
  }

  Future<String> dallE(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'content-Type': 'applcation/json',
        'Authorization': 'Bearer $openApiKey'
      },
      body: jsonEncode(
        {
          'prompt': prompt,
          'n': 1, //for 1 image
          "size": "1024x1024"
        },
      ),
    );
    if (response.statusCode == 200) {
      String imageUrl = jsonDecode(response.body)['data']['0']['url'];
      imageUrl = imageUrl.trim();

      messages.add({'role': 'assistant', 'content': imageUrl});
      return imageUrl;
    }
    return '';
  }
}
