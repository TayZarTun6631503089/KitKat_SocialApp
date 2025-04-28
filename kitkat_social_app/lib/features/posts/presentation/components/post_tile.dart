import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitkat_social_app/features/auth/domain/entities/appUser.dart';
import 'package:kitkat_social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:kitkat_social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:kitkat_social_app/features/posts/domain/entities/comment.dart';
import 'package:kitkat_social_app/features/posts/domain/entities/post.dart';
import 'package:kitkat_social_app/features/posts/presentation/components/comment_tile.dart';
import 'package:kitkat_social_app/features/posts/presentation/cubits/post_cubit.dart';
import 'package:kitkat_social_app/features/posts/presentation/cubits/post_states.dart';
import 'package:kitkat_social_app/features/profile/domain/entities/profile_user.dart';
import 'package:kitkat_social_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:kitkat_social_app/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? deleteOnPressed;
  const PostTile({
    super.key,
    required this.post,
    required this.deleteOnPressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  //Cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnpost = false;

  // Current User
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();

    // get Current User
    getCurrentUser();

    // Fetch post User
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnpost = widget.post.userId == currentUser!.uid;
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  //show Options delete or not
  void showOption() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Post?"),
            actions: [
              //Cencel button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cencel"),
              ),

              //delete button
              TextButton(
                onPressed: () {
                  widget.deleteOnPressed!();
                  Navigator.pop(context);
                },
                child: Text("Delete"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  /*
    Like
 */

  void updateToggleLikePost() {
    // current Like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // smothly flow like UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // back to original
      if (isLiked) {
        widget.post.likes.add(currentUser!.uid);
      } else {
        widget.post.likes.remove(currentUser!.uid);
      }
    });
  }

  // comment
  final commentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add a new comment"),
            content: MyTextField(
              controller: commentTextController,
              hintText: "Type New Comment",
              obsureText: false,
            ),
            actions: [
              //Cencel button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cencel"),
              ),

              //delete button
              TextButton(
                onPressed: () {
                  addCommentPost();
                  Navigator.pop(context);
                },
                child: Text("Save"),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.greenAccent,
                  ),
                  foregroundColor: MaterialStateProperty.all<Color>(
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void addCommentPost() {
    //create new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    } else {}
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  //Build UI
  @override
  Widget build(BuildContext context) {
    final postTime = widget.post.timestamp;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header: avatar + name + (optional) delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Profile picture
                GestureDetector(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(uid: postUser!.uid),
                        ),
                      ),
                  child:
                      postUser?.profileImageUrl != null
                          ? CircleAvatar(
                            radius: 24,
                            backgroundImage: CachedNetworkImageProvider(
                              postUser!.profileImageUrl,
                            ),
                          )
                          : const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.person),
                          ),
                ),
                const SizedBox(width: 12),
                // Username and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${postTime.day}/${postTime.month}/${postTime.year} ${postTime.hour}:${postTime.minute.toString().padLeft(2, '0')}",
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Delete button (only owner)
                if (isOwnpost)
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 24),
                    onPressed: showOption,
                  ),
              ],
            ),
          ),
          // Post Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetworkImage(
              imageUrl: widget.post.imageUrl,
              width: double.infinity,
              height: 340,
              fit: BoxFit.cover,
              placeholder:
                  (context, url) => Container(
                    color: Colors.grey[200],
                    height: 340,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              errorWidget:
                  (context, url, error) => const SizedBox(
                    height: 340,
                    child: Center(child: Icon(Icons.broken_image, size: 40)),
                  ),
            ),
          ),
          // Actions Row (Like, Comment, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                // Like Button
                GestureDetector(
                  onTap: updateToggleLikePost,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      widget.post.likes.contains(currentUser!.uid)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      key: ValueKey(
                        widget.post.likes.contains(currentUser!.uid),
                      ),
                      color:
                          widget.post.likes.contains(currentUser!.uid)
                              ? Colors.redAccent
                              : Colors.grey[700],
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${widget.post.likes.length}",
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                const SizedBox(width: 20),
                // Comment button
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: const Icon(
                    Icons.comment_outlined,
                    size: 26,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${widget.post.comments.length}",
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                Spacer(),
                // Optionally add a bookmark, share, etc.
              ],
            ),
          ),
          // Caption (Username + text)
          if (widget.post.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.black87, fontSize: 16),
                  children: [
                    TextSpan(
                      text: widget.post.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: "  ${widget.post.text}"),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Divider(height: 1, color: Colors.grey[200]),
          ),
          // Comments
          BlocBuilder<PostCubit, PostStates>(
            builder: (context, state) {
              if (state is PostsLoaded) {
                final post = state.posts.firstWhere(
                  (post) => (post.id == widget.post.id),
                  orElse: () => widget.post,
                );
                if (post.comments.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: ListView.separated(
                      itemCount: post.comments.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (_, __) => SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        return CommentTile(comment: comment);
                      },
                    ),
                  );
                }
              }
              if (state is PostsLoading) {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (state is PostsError) {
                return Center(child: Text(state.messages));
              } else {
                return const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "No comments yet",
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
