import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kitkat_social_app/features/auth/domain/entities/appUser.dart';
import 'package:kitkat_social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:kitkat_social_app/features/posts/presentation/components/post_tile.dart';
import 'package:kitkat_social_app/features/posts/presentation/cubits/post_cubit.dart';
import 'package:kitkat_social_app/features/posts/presentation/cubits/post_states.dart';
import 'package:kitkat_social_app/features/profile/presentation/components/bio_box.dart';
import 'package:kitkat_social_app/features/profile/presentation/components/follow_button.dart';
import 'package:kitkat_social_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:kitkat_social_app/features/profile/presentation/cubits/profile_state.dart';
import 'package:kitkat_social_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:kitkat_social_app/features/profile/presentation/pages/follower_page.dart';
import 'package:kitkat_social_app/features/responsives/constrained_scaffold.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  late AppUser? currentUser = authCubit.currentUser;
  int postCount = 0;

  @override
  void initState() {
    super.initState();

    // fetch user profile
    profileCubit.fetchUserProfile(widget.uid);
  }

  /* 

  Follow Unfollow
  
  */
  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // smoother Ui
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      setState(() {
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        } else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          final user = state.profileUser;

          return ConstrainedScaffold(
            body: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double maxWidth =
                      constraints.maxWidth > 600 ? 500 : constraints.maxWidth;
                  return Center(
                    child: Container(
                      width: maxWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // Profile card section
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade100,
                                    const Color.fromARGB(255, 248, 247, 248),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(30),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.08),
                                    blurRadius: 12,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 24,
                                  horizontal:
                                      constraints.maxWidth > 600 ? 32 : 20,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          icon: Icon(Icons.arrow_back),
                                        ),
                                      ],
                                    ),
                                    Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        CircleAvatar(
                                          radius: 56,
                                          backgroundColor: Colors.white,
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: user.profileImageUrl,
                                              width: 104,
                                              height: 104,
                                              fit: BoxFit.cover,
                                              placeholder:
                                                  (context, url) =>
                                                      CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) => Icon(
                                                    Icons.person,
                                                    size: 60,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        if (isOwnPost)
                                          Positioned(
                                            bottom: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap:
                                                  () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              EditProfilePage(
                                                                user: user,
                                                              ),
                                                    ),
                                                  ),
                                              child: CircleAvatar(
                                                backgroundColor: Colors.blue,
                                                radius: 16,
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 14),
                                    Text(
                                      user.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user.email,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 18),
                                    // Stats bar
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 2,
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 2,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                          horizontal: 12,
                                        ),
                                        child: GestureDetector(
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => FollowerPage(
                                                        followers:
                                                            user.followers,
                                                        following:
                                                            user.following,
                                                      ),
                                                ),
                                              ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _buildStat("Posts", postCount),
                                              _verticalDivider(),
                                              _buildStat(
                                                "Followers",
                                                user.followers.length,
                                              ),
                                              _verticalDivider(),
                                              _buildStat(
                                                "Following",
                                                user.following.length,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    // Follow button
                                    if (!isOwnPost)
                                      FollowButton(
                                        onPressed: followButtonPressed,
                                        isFollowing: user.followers.contains(
                                          currentUser!.uid,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            // Bio Section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 6,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bio",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  BioBox(text: user.bio),
                                ],
                              ),
                            ),

                            SizedBox(height: 12),

                            // Posts section
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 6,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Posts",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            BlocBuilder<PostCubit, PostStates>(
                              builder: (context, state) {
                                if (state is PostsLoaded) {
                                  final userPosts =
                                      state.posts
                                          .where(
                                            (post) =>
                                                (post.userId == widget.uid),
                                          )
                                          .toList();
                                  postCount = userPosts.length;
                                  if (userPosts.isEmpty) {
                                    return Center(
                                      child: Text(
                                        "No posts yet.",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    );
                                  }
                                  return ListView.builder(
                                    itemCount: postCount,
                                    shrinkWrap: true,
                                    physics: BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final post = userPosts[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6.0,
                                          horizontal: 8,
                                        ),
                                        child: PostTile(
                                          post: post,
                                          deleteOnPressed:
                                              () => context
                                                  .read<PostCubit>()
                                                  .deletePost(post.id),
                                        ),
                                      );
                                    },
                                  );
                                } else if (state is PostsLoading) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else {
                                  return Center(
                                    child: Text("Error loading posts"),
                                  );
                                }
                              },
                            ),
                            SizedBox(height: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is ProfileLoading) {
          return const ConstrainedScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const Center(child: Text("No Profile found"));
        }
      },
    );
  }

  Widget _buildStat(String label, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 22,
      width: 1.1,
      color: Colors.grey[300],
      margin: EdgeInsets.symmetric(horizontal: 12),
    );
  }
}
