import "package:flutter/material.dart";

double getWidth(BuildContext context, double width) {
  return MediaQuery.of(context).size.width * width / 100;
}

double getHeight(BuildContext context, double height) {
  return MediaQuery.of(context).size.height * height / 100;
}

// sanjeev_k_singh
// Z5(@7t8Q)

String capitalizeFirstLetter(String inputString) {
  return inputString.isEmpty
      ? inputString
      : inputString[0].toUpperCase() + inputString.substring(1);
}

Widget heightSpace(double height) {
  return SizedBox(height: height);
}

Widget widthSpace(double width) {
  return SizedBox(width: width);
}

//*************Snack Bar*********************/

void showSnackBar({
  required BuildContext context,
  required String title,
  String type = "success",
  required int duration,
}) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 10,
      ),
      duration: Duration(milliseconds: duration),
      content: Row(
        children: [
          type == "success"
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                )
              : type == "error"
                  ? const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    )
                  : const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 14,
                    ),
          const SizedBox(width: 10),
          SizedBox(
            width: getWidth(context, 70),
            child: Text(
              overflow: TextOverflow.ellipsis,
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1,
                  fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
      backgroundColor: type == "success"
          ? Colors.green
          : type == "error"
              ? Colors.red
              : Colors.green,
    ),
  );
}
