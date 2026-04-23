import 'package:flutter/material.dart';

class InfoSectionWidget
    extends StatelessWidget {
  final String? title;
  final List<Widget>
      children;

  const InfoSectionWidget({
    super.key,
    this.title,
    required this.children,
  });

  @override
  Widget build(
      BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
              18),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
                20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color:
                Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          if (title != null)
            Padding(
              padding:
                  const EdgeInsets.only(
                      bottom:
                          14),
              child: Text(
                title!,
                style:
                    const TextStyle(
                  fontSize:
                      18,
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
            ),

          ...children,
        ],
      ),
    );
  }
} 