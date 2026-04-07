# Quick Start: Using Tier 1 Features

## 📝 Integration Checklist

### Step 1: Dependency Injection Setup
Create a service locator in your `main.dart`:

```dart
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  getIt.registerSingleton<ChatService>(ChatService());
  getIt.registerSingleton<VideoConsultationService>(VideoConsultationService());
  getIt.registerSingleton<AssessmentService>(AssessmentService());
  getIt.registerSingleton<PaymentService>(PaymentService());
  getIt.registerSingleton<ReviewService>(ReviewService());
  getIt.registerSingleton<AIService>(AIService());
  getIt.registerSingleton<RecommendationService>(RecommendationService());
}

void main() {
  setupServiceLocator();
  runApp(MyApp());
}
```

### Step 2: Wire Up Services in Your Screens

#### Chat Screen Example:
```dart
class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ChatService chatService;
  late String conversationId;

  @override
  void initState() {
    super.initState();
    chatService = getIt<ChatService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: chatService.getMessagesStream(conversationId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final msg = snapshot.data![index];
                    return ListTile(
                      title: Text(msg.content),
                      subtitle: Text(msg.timestamp.toString()),
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(hintText: 'Type message...'),
                    onSubmitted: (text) async {
                      await chatService.sendMessage(
                        conversationId: conversationId,
                        senderId: 'current_user_id',
                        senderName: 'Your Name',
                        senderAvatar: 'your_avatar_url',
                        content: text,
                      );
                    },
                  ),
                ),
                SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: () => print('Send'),
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Assessment Screen Example:
```dart
class AssessmentQuizScreen extends StatefulWidget {
  final String assessmentId;

  const AssessmentQuizScreen({required this.assessmentId});

  @override
  State<AssessmentQuizScreen> createState() => _AssessmentQuizScreenState();
}

class _AssessmentQuizScreenState extends State<AssessmentQuizScreen> {
  late AssessmentService assessmentService;
  int currentQuestionIndex = 0;
  Map<String, String> userAnswers = {};

  @override
  void initState() {
    super.initState();
    assessmentService = getIt<AssessmentService>();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AssessmentQuestion>>(
      future: assessmentService.getAssessmentQuestions(widget.assessmentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Scaffold(body: Center(child: CircularProgressIndicator()));
        
        final questions = snapshot.data!;
        final current = questions[currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('Question ${currentQuestionIndex + 1}/${questions.length}'),
          ),
          body: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question
                Text(
                  current.questionText,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                // Options
                ...current.options.map((option) {
                  final isSelected = userAnswers['q${current.id}'] == option;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        userAnswers['q${current.id}'] = option;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(option),
                    ),
                  );
                }).toList(),
                Spacer(),
                // Next button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentQuestionIndex > 0)
                      ElevatedButton(
                        onPressed: () => setState(() => currentQuestionIndex--),
                        child: Text('Previous'),
                      ),
                    ElevatedButton(
                      onPressed: currentQuestionIndex == questions.length - 1
                          ? () => _submitAssessment(questions)
                          : () => setState(() => currentQuestionIndex++),
                      child: Text(
                        currentQuestionIndex == questions.length - 1 ? 'Submit' : 'Next',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitAssessment(List<AssessmentQuestion> questions) async {
    final answers = userAnswers.entries
        .map((e) => MapEntry(e.key, e.value))
        .toList();

    final result = await assessmentService.submitAssessment(
      userId: 'current_user_id',
      assessmentId: widget.assessmentId,
      answers: answers,
      timeSpentSeconds: 1800,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(
        'Score: ${result.scorePercentage}% - Badge: ${result.badge}'
      )),
    );

    Navigator.pop(context, result);
  }
}
```

#### Chat Bot Widget Example:
```dart
class ChatBotWidget extends StatefulWidget {
  @override
  State<ChatBotWidget> createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  late AIService aiService;
  bool isOpen = false;
  List<Map<String, String>> chatHistory = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    aiService = getIt<AIService>();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isOpen)
          Container(
            width: 300,
            height: 400,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 10)],
            ),
            child: Column(
              children: [
                AppBar(
                  title: Text('Ask Bot'),
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      onPressed: () => setState(() => isOpen = false),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final msg = chatHistory[index];
                      return ListTile(
                        title: Text(msg['text']!),
                        trailing: Text(msg['role']!),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Ask me something...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: () async {
                          final text = controller.text;
                          controller.clear();

                          setState(() {
                            chatHistory.add({'text': text, 'role': 'user'});
                          });

                          final response = await aiService.getChatBotResponse(
                            userMessage: text,
                            userId: 'current_user_id',
                          );

                          setState(() {
                            chatHistory.add({'text': response, 'role': 'bot'});
                          });
                        },
                        child: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (!isOpen)
          FloatingActionButton(
            onPressed: () => setState(() => isOpen = true),
            child: Icon(Icons.chat),
          ),
      ],
    );
  }
}
```

### Step 3: Payment Processing Setup

```dart
// In main.dart, initialize Stripe
import 'package:flutter_stripe/flutter_stripe.dart';

void main() {
  Stripe.publishableKey = 'pk_live_YOUR_PUBLISHABLE_KEY';
  runApp(MyApp());
}
```

### Step 4: Handle Real-Time Updates

All services use Firestore streams for real-time updates. Make sure your Firestore security rules allow access:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /conversations/{conversationId} {
      allow read, write: if request.auth.uid in resource.data.participantIds;
      match /messages/{messageId} {
        allow read, write: if request.auth.uid in resource.data.participantIds;
      }
    }
    match /assessmentResults/{resultId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow write: if request.auth.uid == resource.data.reviewerId;
    }
  }
}
```

### Step 5: Required Packages

Add to your `pubspec.yaml`:

```yaml
dependencies:
  get_it: ^7.6.0  # Service locator
  flutter_stripe: ^10.0.0  # Stripe payments
  agora_rtc_engine: ^6.2.0  # Video (choose Twilio or Agora)
  openai: ^0.27.0  # OpenAI integration (optional)
  intl: ^0.19.0  # Date formatting
```

Install with:
```bash
flutter pub get
```

---

## 🧪 Testing the Features

### Test Real-Time Chat:
```dart
void testChat() async {
  final chatService = getIt<ChatService>();
  
  // Create conversation
  final conv = await chatService.getOrCreateConversation(
    currentUserId: 'user1',
    otherUserId: 'user2',
    currentUserName: 'John',
    otherUserName: 'Jane',
    currentUserAvatar: 'url1',
    otherUserAvatar: 'url2',
  );

  // Send message
  await chatService.sendMessage(
    conversationId: conv.id,
    senderId: 'user1',
    senderName: 'John',
    senderAvatar: 'url1',
    content: 'Hello!',
  );

  print('Chat test passed!');
}
```

### Test Assessment:
```dart
void testAssessment() async {
  final assessmentService = getIt<AssessmentService>();
  
  final assessments = await assessmentService.getAvailableAssessments();
  final assessment = assessments.first;
  
  // Submit answers
  final result = await assessmentService.submitAssessment(
    userId: 'user1',
    assessmentId: assessment.id,
    answers: [
      MapEntry('q1', 'option_a'),
      MapEntry('q2', 'option_b'),
    ],
    timeSpentSeconds: 1800,
  );

  print('Assessment: ${result.scorePercentage}% - Badge: ${result.badge}');
}
```

### Test Recommendations:
```dart
void testRecommendations() async {
  final recService = getIt<RecommendationService>();
  
  // Smart recommendations
  final smart = await recService.getSmartRecommendations('user1');
  print('Smart recs: ${smart.length} projects');

  // Trending
  final trending = await recService.getTrendingProjects('user1');
  print('Trending: ${trending.length} projects');
}
```

---

## 🐛 Debugging Tips

### Monitor Real-Time Updates:
```dart
// Add firebase logging
FirebaseFirestore.instance.collection('conversations')
  .snapshots()
  .listen((snapshot) {
    print('Conversations updated: ${snapshot.docs.length}');
  });
```

### Check Service Status:
```dart
// Verify services are initialized
final chatService = getIt<ChatService>();
final paymentService = getIt<PaymentService>();
print('Services initialized: $chatService, $paymentService');
```

### Test Fraud Detection:
```dart
void testFraudDetection() async {
  final reviewService = getIt<ReviewService>();
  
  // This should be flagged (too short)
  final review = await reviewService.submitReview(
    projectId: 'proj1',
    reviewerId: 'user1',
    reviewedUserId: 'user2',
    rating: 5.0,
    comment: 'Good',
    tags: [],
  );

  print('Review fraud status: ${review.fraudStatus}');
  // Should be 'flagged'
}
```

---

## 🚨 Common Issues & Solutions

### Issue: Stream not updating in UI
**Solution**: Make sure you're using `StreamBuilder` in the build method and checking `connectionState`

### Issue: Payment amounts are wrong
**Solution**: Verify decimal precision - amounts are stored as `double`, convert to cents for Stripe

### Issue: Video token not generated
**Solution**: Ensure Twilio/Agora credentials are set before calling `startConsultation()`

### Issue: Chat messages for wrong conversation
**Solution**: Double-check `conversationId` is correct before calling `sendMessage()`

---

## 📊 Monitoring & Analytics

Track usage of these features:
```dart
// Log feature usage
Future<void> logFeatureUsage(String feature) async {
  await FirebaseAnalytics.instance.logEvent(
    name: 'feature_used',
    parameters: {
      'feature': feature,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    },
  );
}

// Usage examples:
logFeatureUsage('chat_message_sent');
logFeatureUsage('assessment_completed');
logFeatureUsage('payment_processed');
```

---

**All Tier 1 Features Ready for Integration!** 🎉
