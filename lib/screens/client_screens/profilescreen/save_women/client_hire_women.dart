import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

class HireProcessScreen extends StatefulWidget {
  final String mentorName;

  const HireProcessScreen({super.key, required this.mentorName});

  @override
  State<HireProcessScreen> createState() => _HireProcessScreenState();
}

class _HireProcessScreenState extends State<HireProcessScreen> {
  double progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Hire Mentor"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Hiring ${widget.mentorName}",
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 20),

            LinearProgressIndicator(
              value: progress,
              color: AppColors.primary,
              backgroundColor: Colors.grey.shade300,
            ),

            const SizedBox(height: 10),

            Text("${(progress * 100).toInt()}% Completed"),

            const SizedBox(height: 30),

            const Text("Project Details"),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                "You are hiring this mentor for Flutter app development project.",
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  progress += 0.2;
                  if (progress > 1) progress = 1;
                });
              },
              child: const Text("Increase Progress"),
            ),
          ],
        ),
      ),
    );
  }
}
