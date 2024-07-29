import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:project_1/feature_box.dart';
import 'package:project_1/openai_services.dart';
import 'package:project_1/pallete.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openai = OpenAIService();
  String? generatedContent;
  String? generatedUrl;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
  }

  Future<void> initSpeechToText() async {
    bool available = await speechToText.initialize();
    if (available) {
      setState(() {});
    } else {
      // Handle the case where initialization failed.
      // Show a message to the user or log the error.
      print("The user has denied the use of speech recognition.");
    }
  }

  Future<void> startListening() async {
    if (speechToText.isAvailable) {
      await speechToText.listen(onResult: onSpeechResult);
      setState(() {});
    } else {
      // Handle the case where speech recognition is not available.
      // Show a message to the user or log the error.
      print("Speech recognition is not available.");
    }
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
    });
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SELENA',
          style: TextStyle(
              letterSpacing: 2,
              fontFamily: 'Cera Pro',
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        leading: const Icon(Icons.menu),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Stack(
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 25),
                    height: 150,
                    width: 150,
                    decoration: const BoxDecoration(
                      color: Pallete.firstSuggestionBoxColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 15),
                    height: 158,
                    width: 158,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/image/virtualAssistant.png'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Visibility(
              visible: generatedUrl == null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top:
                        30), //cause we want to pass the only on top but in symmetric height is passed on both top and bottom ..so we used .copywith()
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(20).copyWith(topLeft: Radius.zero),
                  border: Border.all(
                    color: Pallete.borderColor,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    generatedContent == null
                        ? 'Good Morning , how can I help you ? '
                        : generatedContent!,
                    style: TextStyle(
                        fontSize: generatedContent == null ? 16 : 12,
                        color: Pallete.mainFontColor,
                        fontFamily: 'Cera Pro'),
                  ),
                ),
              ),
            ),
            if (generatedUrl != null)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(generatedUrl!)),
              ),
            const SizedBox(height: 10),
            Visibility(
              visible: generatedContent == null && generatedUrl == null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                alignment: Alignment.topLeft,
                child: const Text(
                  'Here are a few features ',
                  style: TextStyle(fontFamily: 'Cera Pro', fontSize: 20),
                ),
              ),
            ),
            Visibility(
              visible: generatedContent == null && generatedUrl == null,
              child: const Column(
                children: [
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'ChatGpt',
                    descriptionText:
                        'A smarter way to stay organized and informed with ChatGpt',
                  ),
                  FeatureBox(
                    color: Color.fromARGB(255, 164, 211, 244),
                    headerText: 'Dall-E',
                    descriptionText:
                        'Get inspired and stay creative with your personal assistant powered by Dall-E',
                  ),
                  FeatureBox(
                    color: Pallete.firstSuggestionBoxColor,
                    headerText: 'SmartVoiceAssistant',
                    descriptionText:
                        'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGpt',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (await speechToText.hasPermission &&
              speechToText.isAvailable &&
              !speechToText.isListening) {
            await startListening();
          } else if (speechToText.isListening) {
            final speech = await openai.isPromptGptOrDalle(lastWords);
            if (speech.contains('https')) {
              generatedUrl = speech;
              generatedContent = null;
            } else {
              generatedUrl = null;
              generatedContent = speech;
              await systemSpeak(speech);
            }
            setState(() {});
            await stopListening();
          } else if (!speechToText.isAvailable) {
            await initSpeechToText();
          }
        },
        child: const Icon(Icons.mic),
      ),
    );
  }
}
