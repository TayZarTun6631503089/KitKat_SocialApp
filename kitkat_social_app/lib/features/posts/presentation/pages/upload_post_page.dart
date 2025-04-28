import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitkat_social_app/features/auth/domain/entities/appUser.dart';
import 'package:kitkat_social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:kitkat_social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:kitkat_social_app/features/posts/domain/entities/post.dart';
import 'package:kitkat_social_app/features/posts/presentation/cubits/post_cubit.dart';
import 'package:kitkat_social_app/features/posts/presentation/cubits/post_states.dart';
import 'package:kitkat_social_app/features/responsives/constrained_scaffold.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  PlatformFile? imagePickedFile;
  Uint8List? webImage;
  final textController = TextEditingController();
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  void uploadPost() async {
    if (textController.text.isEmpty || imagePickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both image and caption are required")),
      );
      return;
    }
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      name: currentUser!.name,
      imageUrl: "",
      text: textController.text,
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );
    final postCubit = context.read<PostCubit>();
    try {
      if (kIsWeb) {
        await postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
      } else {
        await postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to upload post: $e")));
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostStates>(
      builder: (context, state) {
        if (state is PostsLoading || state is PostUploading) {
          return ConstrainedScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return buildUploadPage();
      },
      listener: (context, state) {
        if (state is PostsLoaded) {
          Navigator.pop(context);
        } else if (state is PostsError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.messages)));
        }
      },
    );
  }

  Widget buildUploadPage() {
    final imagePreview =
        (kIsWeb && webImage != null)
            ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.memory(
                webImage!,
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
            : (!kIsWeb && imagePickedFile != null)
            ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(
                File(imagePickedFile!.path!),
                height: 280,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
            : Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.image, size: 70, color: Colors.grey[400]),
            );

    return ConstrainedScaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black87),
        elevation: 0.5,
        title: Text(
          "Create Post",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: FloatingActionButton.small(
              onPressed: uploadPost,
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.send, color: Colors.white),
              elevation: 2,
              heroTag: "upload",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueGrey.withOpacity(0.07),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                imagePreview,
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                    onPressed: pickImage,
                    icon: Icon(Icons.image_outlined, color: Colors.white),
                    label: Text(
                      "Pick Image",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                MyTextField(
                  controller: textController,
                  hintText: "Write a caption...",
                  obsureText: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
