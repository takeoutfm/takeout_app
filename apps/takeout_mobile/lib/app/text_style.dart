import 'package:flutter/material.dart';

class AppTextStyle {
  static const title = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: .bold,
  );

  static const subtitle = TextStyle(color: Colors.white70, fontSize: 16);

  static const chip = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
  );

  static const movieTitle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: .bold,
    letterSpacing: 1.2,
  );

  static const movieTagline = TextStyle(
    color: Colors.white70,
    fontSize: 16,
    fontWeight: .w600,
    fontStyle: .italic,
    letterSpacing: 1.2,
    overflow: .ellipsis,
  );

  static const movieVote = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: .w600,
  );

  static const movieRating = subtitle;
  static const movieYear = subtitle;
  static const movieRuntime = subtitle;
  static const movieOverviewTitle = title;

  static const movieOverview = TextStyle(
    color: Colors.white70,
    fontSize: 16,
    height: 1.6,
  );

  static const movieCastTitle = title;

  static const movieRelatedTitle = title;

  static const musicReleaseTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    // letterSpacing: 1.2,
  );

  static const musicArtist = TextStyle(
    color: Colors.white70,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    // letterSpacing: 1.2,
  );

  static const musicYear = subtitle;
  static const musicTrackCount = subtitle;
  static const musicDiscCount = subtitle;
  static const musicArtistSubtitle = subtitle;
  static const musicAlbumSubtitle = subtitle;

  static const musicTrackTitle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const musicDiscNumber = subtitle;

  static const musicRelatedTitle = title;

  static const miniPlayerTitle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    // fontWeight: FontWeight.w600,
  );

  static const miniPlayerSubtitle = TextStyle(
    color: Colors.white70,
    fontSize: 14,
    // fontWeight: FontWeight.w300,
  );

// static const discTitle = TextStyle(
  //   color: Colors.white70,
  //   fontSize: 16,
  //   // fontWeight: FontWeight.w600,
  //   letterSpacing: 1.2,
  // );
}
