import 'package:flutter/material.dart';

class FormInput extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;

  const FormInput({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.maxLines,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: EdgeInsets.only(bottom: 10, left: 20),
        //   child: Text(label!, style: Theme.of(context).textTheme.bodyLarge),
        // ),
        Padding(
          padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
          child: TextFormField(
            autofocus:true,
            controller: controller,
            obscureText: obscureText,
            style:TextStyle(
              fontSize:15,
              fontWeight:FontWeight.w500,
              color:Colors.black
            ),
            validator:
                validator ??
                (value) {
                  if (value!.isEmpty) {
                    return "The $label field is required";
                  }
                  return null;
                },
            onSaved: (value) {
              if (controller != null) {
                controller!.text = value!;
              }
            },
            maxLines: maxLines??1,
            minLines:minLines??1,
            decoration: InputDecoration(

              label:Text(label!, style: Theme.of(context).textTheme.bodyLarge),
              hintText: hintText!,
              hintStyle: Theme.of(context).textTheme.bodySmall,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 234, 214, 140),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Colors.redAccent),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
