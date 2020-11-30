class Comment {
  String authorName;
  String authorImageUrl;
  String text;

  Comment({
    this.authorName,
    this.authorImageUrl,
    this.text,
  });
}

final List<Comment> comments = [
  Comment(
    authorName: 'Angel',
    authorImageUrl: 'https://picsum.photos/650',
    text: 'Loving this photo!!',
  ),
  Comment(
    authorName: 'Charlie',
    authorImageUrl: 'https://picsum.photos/650',
    text: 'One of the best photos of you...',
  ),
  Comment(
    authorName: 'Angelina Martin',
    authorImageUrl: 'https://picsum.photos/650',
    text: 'Can\'t wait for you to post more!',
  ),
  Comment(
    authorName: 'Jax',
    authorImageUrl: 'https://picsum.photos/650',
    text: 'Nice job',
  ),
  Comment(
    authorName: 'Sam Martin',
    authorImageUrl: 'https://picsum.photos/650',
    text: 'Thanks everyone :)',
  ),
];
