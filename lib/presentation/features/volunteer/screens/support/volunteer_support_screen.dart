import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/widgets/chatbot/MinhChatbotSuggestion.dart';
import 'package:cuutrobaolu/presentation/features/volunteer/controllers/volunteer_support_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VolunteerSupportScreen extends StatelessWidget {
  const VolunteerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VolunteerSupportController());
    final inputCtrl = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Hỗ trợ / Chatbot')),
      body: Column(
        children: [
          // Suggestion chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            child: Row(
              children: controller.suggestions
                  .map((s) => Padding(
                        padding: EdgeInsets.only(right: MinhSizes.sm),
                        child: MinhChatbotSuggestion(
                          text: s,
                          onTap: () {
                            controller.sendMessage(s);
                          },
                        ),
                      ))
                  .toList(),
            ),
          ),
          // Messages
          Expanded(
            child: Obx(() {
              final msgs = controller.messages;
              if (msgs.isEmpty) {
                return const Center(child: Text('Hãy đặt câu hỏi cho trợ lý.'));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: MinhSizes.defaultSpace),
                itemCount: msgs.length,
                itemBuilder: (context, index) {
                  final m = msgs[index];
                  final isUser = m['isUser'] == true;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(
                        top: MinhSizes.sm,
                        bottom: MinhSizes.sm / 2,
                        left: isUser ? 60 : 0,
                        right: isUser ? 0 : 60,
                      ),
                      padding: EdgeInsets.all(MinhSizes.defaultSpace),
                      decoration: BoxDecoration(
                        color: isUser ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
                      ),
                      child: Text(m['text'] ?? ''),
                    ),
                  );
                },
              );
            }),
          ),
          // Input
          Padding(
            padding: EdgeInsets.all(MinhSizes.defaultSpace),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: inputCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Nhập câu hỏi...',
                    ),
                    onSubmitted: (value) {
                      controller.sendMessage(value);
                      inputCtrl.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    controller.sendMessage(inputCtrl.text);
                    inputCtrl.clear();
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}


