import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/zoness_controller.dart';
import '../theme/app_theme.dart';

class ZonesScreen extends StatefulWidget {
  const ZonesScreen({super.key});

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  final ZonessController controller = Get.put(ZonessController());

  @override
  void initState() {
    super.initState();
    controller.fetchZones();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Restricted Zones",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.zones.isEmpty) {
          return const Center(
            child: Text(
              "No zones available",
              style: TextStyle(color: AppColors.dim),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.zones.length,
          itemBuilder: (_, index) {
            final zone = controller.zones[index];

            return ZoneCard(zone: zone);
          },
        );
      }),
    );
  }
}

class ZoneCard extends StatelessWidget {
  final dynamic zone;

  const ZoneCard({
    super.key,
    required this.zone,
  });

  @override
  Widget build(BuildContext context) {
    final Color zoneColor = _hexColor(zone.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                CircleAvatar(
                  radius: 10,
                  backgroundColor: zoneColor,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    zone.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: zone.status == "active"
                        ? Colors.green.withOpacity(.15)
                        : Colors.red.withOpacity(.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    zone.status.toUpperCase(),
                    style: TextStyle(
                      color: zone.status == "active"
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),

              ],
            ),

            const SizedBox(height: 15),

            _info("Description", zone.description),

            _info("Type", zone.type),

            _info("Reports", "${zone.reportsCount}"),

            _info("Sensors", "${zone.sensorsCount}"),

            _info(
              "Coordinates",
              "X: ${zone.xPercent}%   Y: ${zone.yPercent}%",
            ),

            _info(
              "Size",
              "W: ${zone.widthPercent}%   H: ${zone.heightPercent}%",
            ),

            _info(
              "Created",
              _formatDate(zone.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          SizedBox(
            width: 95,
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.dim,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
              ),
            ),
          ),

        ],
      ),
    );
  }

  String _formatDate(String? value) {
    if (value == null) return "";

    final d = DateTime.parse(value);

    return "${d.day}/${d.month}/${d.year}";
  }

  Color _hexColor(String? hex) {
    if (hex == null || hex.isEmpty) {
      return Colors.blue;
    }

    final buffer = StringBuffer();

    if (hex.length == 7) {
      buffer.write('ff');
    }

    buffer.write(hex.replaceFirst('#', ''));

    return Color(int.parse(buffer.toString(), radix: 16));
  }
}