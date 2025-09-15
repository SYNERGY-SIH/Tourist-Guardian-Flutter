// lib/pages/chat_bot_page.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_app/utils/colors.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

// ChatMessage class remains the same
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isInteractive;
  final List<String>? options;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isInteractive = false,
    this.options,
  });
}

class ChatBotPage extends StatefulWidget {
  const ChatBotPage({super.key});

  @override
  State<ChatBotPage> createState() => _ChatBotPageState();
}

class _ChatBotPageState extends State<ChatBotPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isBotTyping = false;
  bool _interactiveReplied = false;

  // NEW: State to hold the last detected language
  String _lastDetectedLanguage = 'en';

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  late final RuleBasedChatbot _chatbot;

  @override
  void initState() {
    super.initState();
    _chatbot = RuleBasedChatbot(pairs, reflections: reflections);
    _initSpeech();
    _addBotMessage("Hi Anuj, my name is Radha. How can I help you?");
  }

  // MODIFIED: This function now uses the new BotResponsePayload
  void _handleUserMessage(String text) async {
    if (text.isEmpty) return;
    if (_isListening) _stopListening();
    
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isBotTyping = true;
    });
    _textController.clear();
    _scrollToBottom();
    
    final botResponse = await _chatbot.respond(
      text,
      inputLang: 'auto',
      latitude: 26.1445,
      longitude: 91.7362,
    );

    setState(() {
      _isBotTyping = false;
      // Store the detected language
      _lastDetectedLanguage = botResponse.detectedLanguage;
    });

    for (final response in botResponse.messages) {
      if (response == chatbotInteractiveTrigger) {
        _showTrackingPrompt();
      } else {
        _addBotMessage(response, showImmediately: true);
      }
    }
  }

  void _handleInteractiveReply(String choice) {
    // We send the English version of the choice to the bot
    final englishChoice = (choice == "हो") ? "Yes" : (choice == "नाही" ? "No" : choice);
    
    setState(() {
      _interactiveReplied = true;
      _messages.add(ChatMessage(text: choice, isUser: true));
    });
    _scrollToBottom();

    if (englishChoice == "Yes") {
      _addBotMessage("Great. I've enabled real-time location tracking. Your emergency contacts have been notified.");
    } else {
      _addBotMessage("Okay. Please stay safe and keep me updated if you need anything else.");
    }
  }
  
  // MODIFIED: This function now displays the prompt in the correct language
  void _showTrackingPrompt() {
    String promptText;
    List<String> options;

    if (_lastDetectedLanguage == 'mr') {
      promptText = "हे अनुज, तुम्हाला सुरक्षित वाटेपर्यंत मी तुमचे लोकेशन रिअल टाइममध्ये ट्रॅक करावे असे वाटते का?";
      options = ["हो", "नाही"]; // Yes, No in Marathi
    } else {
      promptText = "Hey Anuj, do you want me to track your location in real time until you feel safe?";
      options = ["Yes", "No"];
    }

    setState(() {
      _interactiveReplied = false;
      _messages.add(
        ChatMessage(
          text: promptText,
          isUser: false,
          isInteractive: true,
          options: options,
        ),
      );
    });
    _scrollToBottom();
  }

  // --- Other methods are unchanged ---
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      _textController.text = result.recognizedWords;
    });
    setState(() => _isListening = true);
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _addBotMessage(String text, {bool showImmediately = false}) {
    Future.delayed(Duration(milliseconds: showImmediately ? 0 : 500), () {
      if (mounted) {
        setState(() => _messages.add(ChatMessage(text: text, isUser: false)));
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Timer(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... Build method is unchanged ...
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Support Chat"),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatMessageBubble(
                  message: message,
                  onOptionSelected: _handleInteractiveReply,
                  isInteractiveDisabled: _interactiveReplied,
                );
              },
            ),
          ),
          if (_isBotTyping)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Row(
                children: [
                  SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  SizedBox(width: 8),
                  Text("Radha is typing..."),
                ],
              ),
            ),
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    // ... This widget is unchanged ...
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.background)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleUserMessage,
                decoration: InputDecoration(
                  hintText: "Type or speak...",
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: AppColors.primary),
              onPressed: _speechEnabled ? (_isListening ? _stopListening : _startListening) : null,
              tooltip: "Speak your message",
            ),
            IconButton.filled(
              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () => _handleUserMessage(_textController.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  // ... This widget is unchanged ...
  final ChatMessage message;
  final bool isInteractiveDisabled;
  final void Function(String) onOptionSelected;

  const _ChatMessageBubble({
    required this.message,
    required this.isInteractiveDisabled,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: message.isUser ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.text,
            style: TextStyle(color: message.isUser ? Colors.white : AppColors.text),
          ),
        ),
        if (message.isInteractive)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: message.options!.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: OutlinedButton(
                    onPressed: isInteractiveDisabled ? null : () => onOptionSelected(option),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: Text(option),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}


// ############################################################################
// #                   BACKEND CHATBOT LOGIC STARTS HERE                      #
// ############################################################################

const String chatbotInteractiveTrigger = "__INTERACTIVE_PROMPT_TRACKING__";

// NEW: A class to hold the bot's response and detected language
class BotResponsePayload {
  final List<String> messages;
  final String detectedLanguage;
  BotResponsePayload(this.messages, this.detectedLanguage);
}

class Chat {
  // ... (Chat class is unchanged)
  final List<MapEntry<RegExp, List<String>>> _pairs;
  final Map<String, String> _reflections;
  final RegExp _regex;
  final Random _random = Random();

  Chat(List<MapEntry<String, List<String>>> pairs, {Map<String, String>? reflections})
      : _pairs = pairs.map((entry) => MapEntry(RegExp(entry.key, caseSensitive: false), entry.value)).toList(),
        _reflections = reflections ?? {},
        _regex = _compileReflections(reflections ?? {});

  static RegExp _compileReflections(Map<String, String> reflections) {
    final sortedKeys = reflections.keys.toList()..sort((a, b) => b.length.compareTo(a.length));
    return RegExp(r"\b(" + sortedKeys.map(RegExp.escape).join("|") + r")\b", caseSensitive: false);
  }

  String _substitute(String input) {
    return input.replaceAllMapped(_regex, (match) {
      final word = match.group(0)!.toLowerCase();
      return _reflections[word] ?? word;
    });
  }

  String _wildcards(String response, RegExpMatch match) {
    var resp = response;
    var pos = resp.indexOf('%');
    while (pos >= 0) {
      final num = int.tryParse(resp.substring(pos + 1, pos + 2));
      if (num != null && num <= match.groupCount) {
        final substitution = _substitute(match.group(num)!);
        resp = resp.substring(0, pos) + substitution + resp.substring(pos + 2);
      }
      pos = resp.indexOf('%', pos + 1);
    }
    return resp;
  }

  String? respond(String input) {
    for (var entry in _pairs) {
      final match = entry.key.firstMatch(input);
      if (match != null) {
        var resp = entry.value[_random.nextInt(entry.value.length)];
        resp = _wildcards(resp, match);
        return resp;
      }
    }
    return null;
  }
}

// MODIFIED: RuleBasedChatbot now returns a BotResponsePayload
class RuleBasedChatbot {
  final Chat chat;
  final GoogleTranslator translator = GoogleTranslator();

  RuleBasedChatbot(List<MapEntry<String, List<String>>> pairs, {Map<String, String>? reflections})
      : chat = Chat(pairs, reflections: reflections);
      
  bool _isEmergency(String englishInput, String originalInput) {
    final englishKeywords = ["sos", "help", "save", "emergency", "danger", "safe"];
    if (englishKeywords.any((word) => englishInput.contains(word))) return true;

    final marathiKeywords = ["मदत", "धोका", "वाचवा", "madat", "dhoka", "vachva"];
    if (marathiKeywords.any((word) => originalInput.toLowerCase().contains(word))) return true;

    return false;
  }

  Future<BotResponsePayload> respond(String userInput, {String inputLang = 'auto', double? latitude, double? longitude}) async {
    try {
      var translationResult = await translator.translate(userInput, from: inputLang, to: 'en');
      String englishInput = translationResult.text.toLowerCase();
      String detectedLanguage = translationResult.sourceLanguage.code;

      if (_isEmergency(englishInput, userInput)) {
        if (latitude != null && longitude != null) {
          final policeStation = await _getNearestPoliceStation(latitude, longitude);
          String policeInfo = "Nearest Police Station: $policeStation";
          String sosReminder = "Please trigger the SOS button if you are in immediate danger.";

          final translatedPoliceInfo = await translator.translate(policeInfo, from: 'en', to: detectedLanguage);
          final translatedSosReminder = await translator.translate(sosReminder, from: 'en', to: detectedLanguage);
          
          final messages = [
            translatedPoliceInfo.text,
            translatedSosReminder.text,
            chatbotInteractiveTrigger,
          ];
          return BotResponsePayload(messages, detectedLanguage);
        } else {
          final translatedMsg = await translator.translate("Please provide your location to find help.", from: 'en', to: detectedLanguage);
          return BotResponsePayload([translatedMsg.text], detectedLanguage);
        }
      }

      String englishResponse = chat.respond(englishInput) ?? "I am sorry, but I do not understand.";
      List<String> messages;

      if (detectedLanguage == 'mr') {
        final finalResponse = await translator.translate(englishResponse, from: 'en', to: 'mr');
        messages = [finalResponse.text];
      } else {
        messages = [englishResponse];
      }
      return BotResponsePayload(messages, detectedLanguage);

    } catch (e) {
      return BotResponsePayload(["Sorry, I'm having trouble connecting. Please check your internet connection."], 'en');
    }
  }

  Future<String> _getNearestPoliceStation(double latitude, double longitude) async {
    // ... This method is unchanged ...
    final url = "https://investigationcamp.com/map.php?latitude=$latitude&longitude=$longitude";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final nearest = data[0];
          String name = nearest["ps_name"] ?? "Unknown";
          String phone = nearest["phone"] ?? "N/A";
          return "$name (Phone: $phone)";
        } else {
          return "No police station data found nearby.";
        }
      } else {
        return "Could not contact emergency services.";
      }
    } catch (e) {
      return "Error fetching police station info.";
    }
  }
}

// Data for the chatbot is unchanged
final reflections = {
  "i am": "you are", "i was": "you were", "i": "you", "i'm": "you are", "i'd": "you would",
  "i've": "you have", "i'll": "you will", "my": "your", "you are": "I am", "you were": "I was",
  "you've": "I have", "you'll": "I will", "your": "my", "yours": "mine", "you": "me", "me": "you"
};

final pairs = [
  MapEntry(r'quit', ["Goodbye!", "It was nice talking to you."]),
  MapEntry(r'my name is (.*)', ["Hello %1, how can I help you today?", "Nice to meet you, %1."]),
  MapEntry(r'what is your name?', ["My name is Radha and I am a friendly chatbot."]),
  MapEntry(r'how are you?', ["I am doing well, thank you!", "I'm doing great, thanks for asking."]),
  MapEntry(r'i like (.*)', ["Why do you like %1?", "That's interesting. What else do you like?"]),
  MapEntry(r'(.*) weather (.*)', ["I'm sorry, I cannot check the weather. I am a safety assistant."]),
  MapEntry(r'who are you?', ["I am Radha, your personal safety assistant."]),
  MapEntry(r'hi|hello|hey', ["Hello!", "Hi there!", "Hey! How can I help?"]),
  MapEntry(r'(.*)', ["I am sorry, I don't understand that. I can only assist with safety concerns and basic chat."]),
];