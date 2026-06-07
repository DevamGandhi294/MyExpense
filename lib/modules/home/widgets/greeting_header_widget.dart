import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myexpense/modules/home/home_controller.dart';

class GreetingHeaderWidget extends GetView<HomeController> {
  const GreetingHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Left: greeting + date ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  'Hello, ${controller.userName.value} 👋',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                )),
                const SizedBox(height: 4),
                Obx(() => Text(
                  controller.monthLabel,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                )),
              ],
            ),
          ),

          // ── Right: Monthly badge + avatar ─────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar circle with user photo or initials
              _buildAvatar(),
              const SizedBox(height: 8),
              // Monthly pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD0DCFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 12, color: Colors.indigo.shade400),
                    const SizedBox(width: 4),
                    Text(
                      'Monthly',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.indigo.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final user = FirebaseAuth.instance.currentUser;
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFF1A237E),
      backgroundImage:
          (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
      child: (user?.photoURL == null)
          ? Obx(() => Text(
                controller.userName.value.isNotEmpty
                    ? controller.userName.value[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ))
          : null,
    );
  }
}