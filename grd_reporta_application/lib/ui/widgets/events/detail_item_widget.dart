import 'package:flutter/material.dart';

class DetailItemWidget
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DetailItemWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(
      BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(
              bottom: 16),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Icon(icon,
              size: 20),

          const SizedBox(
              width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                    fontSize:
                        13,
                  ),
                ),

                const SizedBox(
                    height:
                        3),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontSize:
                        16,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}