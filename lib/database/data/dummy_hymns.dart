import 'package:hymns/models/hymn.dart';

// List<Hymn> allHymns = [
//   Hymn(
//     hymnBookId: 1,
//     title: 'Amazing Grace',
//     number: 101,
//     sections: [
//       {
//         'type': 'verse',
//         'number': 1,
//         'phrases': [
//           'Amazing grace! How sweet the sound',
//           'That saved a wretch like me!',
//           'I once was lost, but now am found;',
//           'Was blind, but now I see.'
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 2,
//         'phrases': [
//           '’Twas grace that taught my heart to fear,',
//           'And grace my fears relieved;',
//           'How precious did that grace appear',
//           'The hour I first believed.'
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 3,
//         'phrases': [
//           'The Lord has promised good to me,',
//           'His word my hope secures;',
//           'He will my shield and portion be,',
//           'As long as life endures.'
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 1,
//         'phrases': [
//           'Amazing grace! How sweet the sound',
//           'That saved a wretch like me!',
//         ],
//       },
//     ],
//   ),
//   Hymn(
//     hymnBookId: 1,
//     title: 'How Great Thou Art',
//     number: 101,
//     sections: [
//       {
//         'type': 'verse',
//         'number': 1,
//         'phrases': [
//           'O Lord my God, when I in awesome wonder',
//           'Consider all the works Thy hands have made',
//           'I see the stars, I hear the rolling thunder',
//           'Thy power throughout the universe displayed',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 1,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 2,
//         'phrases': [
//           'When through the woods and forest glades I wander',
//           'And hear the birds sing sweetly in the trees',
//           'When I look down from lofty mountain grandeur',
//           'And hear the brook and feel the gentle breeze',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 2,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 3,
//         'phrases': [
//           'And when I think that God, His Son not sparing',
//           'Sent Him to die, I scarce can take it in',
//           'That on the cross, my burden gladly bearing',
//           'He bled and died to take away my sin',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 3,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 4,
//         'phrases': [
//           'When Christ shall come with shout of acclamation',
//           'And take me home, what joy shall fill my heart',
//           'Then I shall bow in humble adoration',
//           'And there proclaim, my God, how great Thou art',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 4,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//     ],
//   ),
//   Hymn(
//     hymnBookId: 1,
//     title: 'Great Is Thy Faithfulness',
//     number: 102,
//     sections: [
//       {
//         'type': 'verse',
//         'number': 1,
//         'phrases': [
//           'Great is Thy faithfulness, O God my Father',
//           'There is no shadow of turning with Thee',
//           'Thou changest not, Thy compassions, they fail not',
//           'As Thou hast been, Thou forever wilt be',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 1,
//         'phrases': [
//           'Great is Thy faithfulness! Great is Thy faithfulness!',
//           'Morning by morning new mercies I see',
//           'All I have needed Thy hand hath provided',
//           'Great is Thy faithfulness, Lord, unto me!',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 2,
//         'phrases': [
//           'Summer and winter and springtime and harvest',
//           'Sun, moon, and stars in their courses above',
//           'Join with all nature in manifold witness',
//           'To Thy great faithfulness, mercy, and love',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 2,
//         'phrases': [
//           'Great is Thy faithfulness! Great is Thy faithfulness!',
//           'Morning by morning new mercies I see',
//           'All I have needed Thy hand hath provided',
//           'Great is Thy faithfulness, Lord, unto me!',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 3,
//         'phrases': [
//           'Pardon for sin and a peace that endureth',
//           'Thine own dear presence to cheer and to guide',
//           'Strength for today and bright hope for tomorrow',
//           'Blessings all mine, with ten thousand beside!',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 3,
//         'phrases': [
//           'Great is Thy faithfulness! Great is Thy faithfulness!',
//           'Morning by morning new mercies I see',
//           'All I have needed Thy hand hath provided',
//           'Great is Thy faithfulness, Lord, unto me!',
//         ],
//       },
//     ],
//   ),
//   Hymn(
//     hymnBookId: 1,
//     title: 'Holy, Holy, Holy',
//     number: 103,
//     sections: [
//       {
//         'type': 'verse',
//         'number': 1,
//         'phrases': [
//           'Holy, holy, holy! Lord God Almighty!',
//           'Early in the morning our song shall rise to Thee;',
//           'Holy, holy, holy! Merciful and mighty!',
//           'God in three Persons, blessed Trinity!'
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 2,
//         'phrases': [
//           'Holy, holy, holy! All the saints adore Thee,',
//           'Casting down their golden crowns around the glassy sea;',
//           'Cherubim and seraphim falling down before Thee,',
//           'Which wert, and art, and evermore shalt be.'
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 3,
//         'phrases': [
//           'Holy, holy, holy! Though the darkness hide Thee,',
//           'Though the eye of sinful man Thy glory may not see,',
//           'Only Thou art holy; there is none beside Thee,',
//           'Perfect in power, in love, and purity.'
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 4,
//         'phrases': [
//           'Holy, holy, holy! Lord God Almighty!',
//           'All Thy works shall praise Thy name, in earth, and sky, and sea;',
//           'Holy, holy, holy! Merciful and mighty!',
//           'God in three Persons, blessed Trinity!'
//         ],
//       },
//     ],
//   ),
//   Hymn(
//     hymnBookId: 1,
//     title: 'How Great Thou Art',
//     number: 101,
//     sections: [
//       {
//         'type': 'verse',
//         'number': 1,
//         'phrases': [
//           'O Lord my God, when I in awesome wonder',
//           'Consider all the works Thy hands have made',
//           'I see the stars, I hear the rolling thunder',
//           'Thy power throughout the universe displayed',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 1,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 2,
//         'phrases': [
//           'When through the woods and forest glades I wander',
//           'And hear the birds sing sweetly in the trees',
//           'When I look down from lofty mountain grandeur',
//           'And hear the brook and feel the gentle breeze',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 2,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 3,
//         'phrases': [
//           'And when I think that God, His Son not sparing',
//           'Sent Him to die, I scarce can take it in',
//           'That on the cross, my burden gladly bearing',
//           'He bled and died to take away my sin',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 3,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 4,
//         'phrases': [
//           'When Christ shall come with shout of acclamation',
//           'And take me home, what joy shall fill my heart',
//           'Then I shall bow in humble adoration',
//           'And there proclaim, my God, how great Thou art',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 4,
//         'phrases': [
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//           'Then sings my soul, my Savior God to Thee',
//           'How great Thou art, how great Thou art',
//         ],
//       },
//     ],
//   ),
//   Hymn(
//     hymnBookId: 1,
//     title: 'Jesus Loves Me',
//     number: 103,
//     sections: [
//       {
//         'type': 'verse',
//         'number': 1,
//         'phrases': [
//           'Jesus loves me! This I know',
//           'For the Bible tells me so',
//           'Little ones to Him belong',
//           'They are weak, but He is strong',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 1,
//         'phrases': [
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'The Bible tells me so',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 2,
//         'phrases': [
//           'Jesus loves me! He who died',
//           'Heaven’s gate to open wide',
//           'He will wash away my sin',
//           'Let His little child come in',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 2,
//         'phrases': [
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'The Bible tells me so',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 3,
//         'phrases': [
//           'Jesus loves me! Loves me still',
//           'Though I’m very weak and ill',
//           'From His shining throne on high',
//           'Comes to watch me where I lie',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 3,
//         'phrases': [
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'The Bible tells me so',
//         ],
//       },
//       {
//         'type': 'verse',
//         'number': 4,
//         'phrases': [
//           'Jesus loves me! He will stay',
//           'Close beside me all the way',
//           'If I love Him when I die',
//           'He will take me home on high',
//         ],
//       },
//       {
//         'type': 'refrain',
//         'number': 4,
//         'phrases': [
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'Yes, Jesus loves me!',
//           'The Bible tells me so',
//         ],
//       },
//     ],
//   ),
// ];

List<Hymn> allHymns = [];
