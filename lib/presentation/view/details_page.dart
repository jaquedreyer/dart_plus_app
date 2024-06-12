 import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/dao/favorites_dao_impl.dart';
import '../../domain/interfaces/models/media.dart';
import '../bloc/favorites/favorite_bloc.dart';
import '../bloc/videos_popular_movie/videos_popular_movie_bloc.dart';
import '../styles/strings.dart';
import '../widgets/favorite_icon.dart';
import '../widgets/genre_label.dart';
import '../widgets/list_view_horizontal.dart';
import '../widgets/media_trailer.dart';
import '../widgets/story_line.dart';
import '../widgets/title_section.dart';

@RoutePage()
class DetailsPage extends StatelessWidget {

  final Media media;
  final List<Media> moviesList;


  const DetailsPage({
    super.key, required this.media, required this.moviesList,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteDao = FavoritesDaoImpl();

    final videoPopularMovieBloc =
        BlocProvider.of<VideosPopularMovieBloc>(context);

    videoPopularMovieBloc.add(GetTrailerPopularMovies(media.id));

    String voteStar(double vote) {
      var voteStar = vote / 2;
      return voteStar.toStringAsFixed(1);
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.6,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    "https://image.tmdb.org/t/p/w500${media.posterPath}",
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: WidgetTitleSection(
                                title: media.title,
                                sizeTitle: 22.0,
                                padding: 0,
                              ),
                            ),
                          ),
                          BlocProvider(
                            create: (context) =>
                                FavoriteBloc(favoriteDao)..add(LoadFavorite(media)),
                            child: FavoriteIconWidget(
                              media: media,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      GenreLabelWidget(media: media, isCompact: false,),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.yellow,
                                size: 18.0,
                              ),
                              Text(
                                "${voteStar(media.voteAverage)}/5.0",
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 8.0,
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      WidgetStoryLine(
                        synopsisTitle: StringsConstants.synopsis,
                        synopsisText: media.overview,
                        width: MediaQuery.of(context).size.width,
                        padding: 0,
                        textColor: Colors.white,
                      ),
                      const SizedBox(height: 16.0),
                      BlocBuilder<VideosPopularMovieBloc,
                          VideosPopularMovieState>(
                        builder: (context, state) {
                          if (state is TrailerPopularMovieLoading) {
                            return const CircularProgressIndicator();
                          }

                          if (state is TrailerPopularMovieLoaded) {
                            final String key = state.keyVideo;
                            return WidgetMediaTrailer(videoKey: key);
                          }

                          if (state is TrailerPopularMovieError) {
                            return const Center(
                              heightFactor: 0.01,
                            );
                          }
                          return const Center();
                        },
                      ),
                      const SizedBox(height: 16.0),
                      const WidgetTitleSection(
                        title: StringsConstants.recommended,
                        padding: 5,
                      ),
                      const SizedBox(height: 4.0),
                      WidgetListViewHorizontal(mediaItems: moviesList),
                    ],
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
