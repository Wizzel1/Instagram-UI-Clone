import 'package:flutter/material.dart';
import 'package:instagram_getx_clone/models/example_data.dart';

class ProfileHighlightStories extends StatelessWidget {
  final ScrollController _storySC = ScrollController();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        color: Colors.white,
        height: 120.0,
        width: double.infinity,
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          controller: _storySC,
          itemCount: exampleStories.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return buildStoryColumn(index);
          },
        ),
      ),
    );
  }

  Column buildStoryColumn(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14.0),
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(70.0),
            border: Border.all(
              width: 1.0,
              color: Colors.grey,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(3),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(70.0),
                child: Image(
                  height: 70,
                  width: 70,
                  image: NetworkImage(users[index].userImageUrl),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Text(
          "Test",
          style: TextStyle(fontSize: 12.0),
        )
      ],
    );
  }
}
