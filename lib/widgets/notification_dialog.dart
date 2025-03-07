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
    // Journal des détails du trajet pour le débogage
    print("[NotificationDialog] Détails du trajet: ${widget.tripDetailsInfo}");

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // En-tête avec icône et titre
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
                      "NOUVELLE DEMANDE",
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

              // Section des détails du trajet
              _buildDetailRow(
                icon: Icons.location_on,
                iconColor: Colors.green,
                label: "Adresse de départ",
                value: widget.tripDetailsInfo?.pickAddress ?? "Inconnu",
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.location_on,
                iconColor: Colors.red,
                label: "Destination",
                value: widget.tripDetailsInfo?.dropOffAddress ?? "Inconnu",
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.person,
                iconColor: Colors.blue,
                label: "client",
                value: widget.tripDetailsInfo?.userName ?? "Inconnu",
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                icon: Icons.phone,
                iconColor: Colors.blueAccent,
                label: "Téléphone",
                value: widget.tripDetailsInfo?.userPhone ?? "Inconnu",
              ),

              const SizedBox(height: 16),

              // Section d'inventaire
              _buildInventoryDetails(),

              const SizedBox(height: 24),

              // Boutons Accepter/Refuser
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print("[NotificationDialog] ACCEPTER pressé");
                      Navigator.pop(context, "accept");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "ACCEPTER",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print("[NotificationDialog] REFUSER pressé");
                      Navigator.pop(context, "decline");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      "REFUSER",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget pour afficher l'inventaire
  Widget _buildInventoryDetails() {
    if (widget.tripDetailsInfo?.totalItems == null ||
        widget.tripDetailsInfo?.totalItems == 0) {
      return const SizedBox(); // Ne rien afficher si pas d'inventaire
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          "Inventaire",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[700],
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          icon: Icons.list,
          iconColor: Colors.brown,
          label: "Nombre d'objets",
          value: "${widget.tripDetailsInfo?.totalItems} objets",
        ),
        _buildDetailRow(
          icon: Icons.straighten,
          iconColor: Colors.orange,
          label: "Volume total",
          value: "${widget.tripDetailsInfo?.totalVolume?.toStringAsFixed(2)} m³",
        ),
        const SizedBox(height: 8),

        // Liste horizontale des objets
        Container(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.tripDetailsInfo?.inventoryList?.length ?? 0,
            itemBuilder: (context, index) {
              var item = widget.tripDetailsInfo!.inventoryList![index];
              return _buildInventoryItem(item);
            },
          ),
        ),
      ],
    );
  }

  /// Widget pour afficher un élément de l'inventaire
  Widget _buildInventoryItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(right: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item["name"] ?? "Objet inconnu",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item["category"] ?? "Type inconnu",
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
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