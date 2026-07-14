// enum ZoneLevel { noEntry, restricted, monitored }
//
// class MaritimeZone {
//   final String id;
//   final String name;
//   final String coordRange;
//   final String description;
//   final ZoneLevel level;
//
//   const MaritimeZone({
//     required this.id,
//     required this.name,
//     required this.coordRange,
//     required this.description,
//     required this.level,
//   });
//
//   /// Value embedded into a submitted report so the Marine Department
//   /// gets a precise reference even without live GPS.
//   String get reportValue => '$name ($coordRange)';
//
//   String get levelLabel {
//     switch (level) {
//       case ZoneLevel.noEntry:
//         return 'NO ENTRY';
//       case ZoneLevel.restricted:
//         return 'PERMIT REQUIRED';
//       case ZoneLevel.monitored:
//         return 'MONITORED';
//     }
//   }
// }
//
// /// Real restricted / protected maritime areas along the Tanzanian coast.
// /// Coordinates are approximate bounding ranges for citizen-facing display.
// const List<MaritimeZone> tanzaniaZones = [
//   MaritimeZone(
//     name: 'Zanzibar Channel — Marine Reserve',
//     coordRange: '5.7°S–6.2°S, 39.1°E–39.5°E',
//     description:
//         'The channel between Unguja Island and the mainland. Restricted commercial '
//         'fishing and vessel transit. Critical dugong and dolphin habitat.',
//     level: ZoneLevel.noEntry,
//   ),
//   MaritimeZone(
//     name: 'Pemba Island — Northern Exclusion Zone',
//     coordRange: '4.9°S–5.2°S, 39.6°E–40.0°E',
//     description:
//         'Northern waters around Pemba. Active naval patrol area. Unauthorised '
//         'vessels face immediate interception.',
//     level: ZoneLevel.noEntry,
//   ),
//   MaritimeZone(
//     name: 'Dar es Salaam Port Exclusion Zone',
//     coordRange: '6.8°S, 39.3°E — 500m perimeter',
//     description:
//         '500-metre security perimeter around Dar es Salaam main port. No '
//         'unauthorised vessels. Constant coast guard patrol.',
//     level: ZoneLevel.noEntry,
//   ),
//   MaritimeZone(
//     name: 'Rufiji River Delta — Selous Buffer',
//     coordRange: '7.8°S–8.1°S, 39.3°E–39.6°E',
//     description:
//         'Delta waters bordering the Selous Game Reserve. Fishing and anchoring '
//         'require a Fisheries Department permit. Protected mangrove ecosystem.',
//     level: ZoneLevel.restricted,
//   ),
//   MaritimeZone(
//     name: 'Mafia Island Marine Park',
//     coordRange: '7.8°S–8.1°S, 39.6°E–39.9°E',
//     description:
//         "Tanzania's first marine park. Commercial fishing and trawling "
//         'prohibited. Coral reef restoration zone.',
//     level: ZoneLevel.restricted,
//   ),
//   MaritimeZone(
//     name: 'Tanga Coelacanth Marine Park',
//     coordRange: '4.8°S–5.1°S, 39.0°E–39.4°E',
//     description:
//         'Habitat of the rare coelacanth fish. Bottom trawling and anchoring '
//         'strictly banned. Science permit required for research vessels.',
//     level: ZoneLevel.restricted,
//   ),
//   MaritimeZone(
//     name: 'Mnazi Bay–Ruvuma Estuary Marine Park',
//     coordRange: '10.3°S–10.8°S, 40.3°E–40.6°E',
//     description:
//         'Southern Tanzania near the Mozambique border. Seagrass and coral '
//         'protection zone. Seasonal fishing restrictions.',
//     level: ZoneLevel.monitored,
//   ),
//   MaritimeZone(
//     name: 'Mwamba-Wamba Coral Garden',
//     coordRange: '3.6°S–3.9°S, 39.8°E–40.1°E',
//     description:
//         'Northern coast coral garden. Anchoring on live coral prohibited. '
//         'Vessels must use designated mooring buoys only.',
//     level: ZoneLevel.monitored,
//   ),
//   MaritimeZone(
//     name: 'Chwaka Bay — Zanzibar East Coast',
//     coordRange: '6.1°S–6.4°S, 39.5°E–39.7°E',
//     description:
//         "Seagrass beds and mangroves on Zanzibar's east coast. Motorised "
//         'vessel speed limit enforced. Net fishing prohibited in core zone.',
//     level: ZoneLevel.monitored,
//   ),
// ];
