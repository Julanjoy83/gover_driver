import 'package:flutter/material.dart';
import 'package:gover_driver_app/global.dart';
import 'package:gover_driver_app/model/trip_details.dart';

class NotificationDialog extends StatefulWidget {
  final TripDetails? tripDetailsInfo;

  const NotificationDialog({Key? key, this.tripDetailsInfo}) : super(key: key);

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  @override
  Widget build(BuildContext context) {
    // Log trip details for debugging
    print("[NotificationDialog] Trip Details: ${widget.tripDetailsInfo}");

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.car_rental,
                    size: 48,
                    color: Colors.deepPurple[700],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "NEW TRIP REQUEST",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Trip details section
            _buildDetailRow(
              icon: Icons.location_on,
              iconColor: Colors.green,
              label: "Pick-up",
              value: widget.tripDetailsInfo?.pickAddress ?? "Unknown",
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.location_on,
              iconColor: Colors.red,
              label: "Drop-off",
              value: widget.tripDetailsInfo?.dropOffAddress ?? "Unknown",
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.person,
              iconColor: Colors.blue,
              label: "Passenger",
              value: widget.tripDetailsInfo?.userName ?? "Unknown",
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              icon: Icons.phone,
              iconColor: Colors.blueAccent,
              label: "Phone",
              value: widget.tripDetailsInfo?.userPhone ?? "Unknown",
            ),
            const SizedBox(height: 24),
            // Accept/Decline buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print("[NotificationDialog] ACCEPT pressed");
                    Navigator.pop(context, "accept");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "ACCEPT",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    print("[NotificationDialog] DECLINE pressed");
                    Navigator.pop(context, "decline");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text(
                    "DECLINE",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}