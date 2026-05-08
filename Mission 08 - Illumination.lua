--[[
  Vereinfachtes Voice Over System – alles in einer Datei
  Verwendung:
    1. Im Mission Editor per "DO SCRIPT FILE" laden
    2. Dann per "DO SCRIPT" z. B. triggerVoiceOver(101) aufrufen
    3. Timing wird ausschließlich über den Mission Editor gesteuert
--]]

local voiceOvers = {
  [801] = {
    oggFile = "AUDIO/801.ogg",
    subtitle = "Two, radio check on victor.",
    unitName = "YOU",
    duration = 3.0
  },
  [802] = {
    oggFile = "AUDIO/802.ogg",
    subtitle = "One, Loud and Clear. No time for chit chat, enemy tanks are rolling towards the rhine river. Let's get those birds in the air.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [803] = {
    oggFile = "AUDIO/803.ogg",
    subtitle = "Roger that, two is ready to taxi.",
    unitName = "YOU",
    duration = 5.0
  },
  [804] = {
    oggFile = "AUDIO/804.ogg",
    subtitle = "Sembach Tower, Hawg Two. Two times A-10 at ... parking. Request taxi to active runway.",
    unitName = "MUDSHARK",
    duration = 12.0
  },
  [805] = {
    oggFile = "AUDIO/805.ogg",
    subtitle = "Makes sense ...",
    unitName = "YOU",
    duration = 3.0
  },
  [806] = {
    oggFile = "AUDIO/806.ogg",
    subtitle = "For departure, we follow the tower departure instructions. Once we have reached the ordered flight level, we’ll check in with Magic and proceed to our holding.",
    unitName = "MUDSHARK",
    duration = 12.0
  },
  [807] = {
    oggFile = "AUDIO/707.ogg",
    subtitle = "At holding, we’ll wait for possible tasking from Magic.",
    unitName = "MUDSHARK",
    duration = 7.0
  },
  [808] = {
    oggFile = "AUDIO/708.ogg",
    subtitle = "Once we are finished with our tasking we will return to base.",
    unitName = "MUDSHARK",
    duration = 7.0
  },
  [809] = {
    oggFile = "AUDIO/709.ogg",
    subtitle = "Copy that and Two is ready to taxi.",
    unitName = "YOU",
    duration = 5.0
  },
  [810] = {
    oggFile = "AUDIO/810.ogg",
    subtitle = "Sembach Tower, Hawg Two. Two times A-10 at parking Foxtrot. Request taxi to active runway.",
    unitName = "MUDSHARK",
    duration = 8.0
  },
  [811] = {
    oggFile = "AUDIO/811.ogg",
    subtitle = "Weather is poor today. Light rain and fog, visibility at 5000 feet. Expect omni-directional departure. Cleared to taxi via Foxtrot, Echo and Alpha to runway Two Five.",
    unitName = "SEMBACH TOWER",
    duration = 12.0
  },
  [812] = {
    oggFile = "AUDIO/812.ogg",
    subtitle = "Cleared to taxi via Foxtrot, Echo and Alpha to runway Two Five, Hawg Two.",
    unitName = "MUDSHARK",
    duration = 8.0
  },
  [813] = {
    oggFile = "AUDIO/813.ogg",
    subtitle = "Hawg Two, line up runway Two Five. After takeoff, fly heading three two zero, climb to 5000 feet. Wind is 094 at 6 knots, Altimeter 29.89 . Cleared for takeoff runway Two Five.",
    unitName = "SEMBACH TOWER",
    duration = 12.0
  },
  [814] = {
    oggFile = "AUDIO/814.ogg",
    subtitle = "Cleared for takeoff runway Two Five. After takeoff heading Two Seven Zero, when passing 3000 feet proceed as fragged. Hawg Two.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [815] = {
    oggFile = "AUDIO/715.ogg",
    subtitle = "Hawg Two Two, wheels up.",
    unitName = "YOU",
    duration = 3.0
  },
  [816] = {
    oggFile = "AUDIO/716.ogg",
    subtitle = "Sembach Tower, Hawg Two. Passing three thousand feet, turning waypoint Two. Switching to Magic.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [817] = {
    oggFile = "AUDIO/817.ogg",
    subtitle = "Copy, continue and push Magic.",
    unitName = "SEMBACH TOWER",
    duration = 5.0
  },
  [818] = {
    oggFile = "AUDIO/818.ogg",
    subtitle = "Hawg Two.",
    unitName = "MUDSHARK",
    duration = 2.0
  },
  [819] = {
    oggFile = "AUDIO/819.ogg",
    subtitle = "Magic, Hawg Two. Two A-10s outbound from Sembach, tasked for standby CAS. Climbing FL120, proceeding to holding, checking in.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [820] = {
    oggFile = "AUDIO/820.ogg",
    subtitle = "Hawg Two, Magic. Sweet, continue as fragged and standby for sitrep.",
    unitName = "MAGIC",
    duration = 6.0
  },
  [821] = {
    oggFile = "AUDIO/821.ogg",
    subtitle = "Proceeding to holing, Hawg Two.",
    unitName = "MUDSHARK",
    duration = 4.0
  },
  [822] = {
    oggFile = "AUDIO/822.ogg",
    subtitle = "Hawg Two, Magic. Sitrep: ground situation is critical. Warsaw Pact forces have reached the outer districts of Frankfurt, defenses are under heavy pressure. Enemy units are attempting to bypass the city from the north and south. Despite the heavy fog — possibly using it as cover — enemy ground forces continue to advance. Remain in holding. I’ll call you in as soon as visibility improves and tasking becomes available.",
    unitName = "MAGIC",
    duration = 30.0
  },
  [823] = {
    oggFile = "AUDIO/823.ogg",
    subtitle = "In the air situation is more favorable. We maintain air superiority within our airspace, and largely beyond the forward lines as well. Our control of the air is being challenged intermittently, but CAP flights have the situation mostly under control. Current picture is clear, but this can change at any time. Stay in holding and monitor Magic for further picture updates and tasking.",
    unitName = "MAGIC",
    duration = 30.0
  },
  [824] = {
    oggFile = "AUDIO/824.ogg",
    subtitle = "Magic, Hawg Two. On station at holding, ready for tasking.",
    unitName = "MUDSHARK",
    duration = 5.0
  },
  [825] = {
    oggFile = "AUDIO/825.ogg",
    subtitle = "Hawg Two, Magic. Roger. Weather currently prevents any air-to-ground operations. Remain in holding and stand by for further instructions.",
    unitName = "MAGIC",
    duration = 10.0
  },
  [826] = {
    oggFile = "AUDIO/826.ogg",
    subtitle = "Wilco, Hawg Two.",
    unitName = "MUDSHARK",
    duration = 3.0
  },
  [827] = {
    oggFile = "AUDIO/827.ogg",
    subtitle = "Colt One, Magic. New Popup. Designated hostile, called Western Group. Commit western group BRA ... ... ...",
    unitName = "MAGIC",
    duration = 10.0
  },
  [828] = {
    oggFile = "AUDIO/828.ogg",
    subtitle = "Commiting Western Group...",
    unitName = "COLT-1",
    duration = 6.0
  },
  [829] = {
    oggFile = "AUDIO/829.ogg",
    subtitle = "Enfield Six, Magic. New Popup, northern group. commit BRA ... ... ...",
    unitName = "MAGIC",
    duration = 10.0
  },
  [830] = {
    oggFile = "AUDIO/830.ogg",
    subtitle = "Magic, Enflied Six, copy. Commiting Bandits BRA ... .. ...",
    unitName = "ENFIELD-6",
    duration = 10.0
  },
  [831] = {
    oggFile = "AUDIO/831.ogg",
    subtitle = "Sounds like our air-to-air guys have their hands full. Doesn’t look like the weather bothers them much up there.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [832] = {
    oggFile = "AUDIO/832.ogg",
    subtitle = "Yeah. And if you look at the reports, they’re doing a solid job. Same on the ground, too. Our losses are lower than theirs.",
    unitName = "YOU",
    duration = 7.0
  },
  [833] = {
    oggFile = "AUDIO/833.ogg",
    subtitle = "True… but it doesn’t really change the math. They’ve got numbers we can’t match. And it feels like their losses don’t slow them down at all. Every time we take out a jet, a tank, a squad… another one shows up. They just keep pushing into our lines until we’re worn out, or we run short on ammo and fuel, and then we’re forced to fall back.",
    unitName = "MUDSHARK",
    duration = 20.0
  },
  [834] = {
    oggFile = "AUDIO/834.ogg",
    subtitle = "I just hope the reinforcements get here soon. We need help, fast… or this is going to get out of control.",
    unitName = "YOU",
    duration = 8.0
  },
  [835] = {
    oggFile = "AUDIO/835.ogg",
    subtitle = "I hope so too. But I’ve got a bad feeling it’ll take longer than we want.  I’m not trying to be dramatic… but I can see us falling back behind the Rhine. It’s the one natural line that actually buys us time… time to reorganize… time to plan… maybe even time for diplomacy.",
    unitName = "MUDSHARK",
    duration = 15.0
  },
  [836] = {
    oggFile = "AUDIO/836.ogg",
    subtitle = "That’s not exactly an optimistic picture. Have you heard anything about northern Germany? How’s it looking up there?",
    unitName = "YOU",
    duration = 7.0
  },
  [837] = {
    oggFile = "AUDIO/837.ogg",
    subtitle = "A bit better… from what I’ve heard. They still haven’t taken Hamburg, but they’re right outside the city. And there were attempted landings near Kiel, from the Baltic. Most of those were pushed back.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [838] = {
    oggFile = "AUDIO/738.ogg",
    subtitle = "But south of Hamburg… not good. Around Hanover they’ve pushed forward. If they swing north from there, they could try to cut Hamburg off. That’s the real danger.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [839] = {
    oggFile = "AUDIO/839.ogg",
    subtitle = "We’re setting up new defensive lines along the Weser now. So the plan might be… hold the Rhine in the south… hold the Weser in the north… and buy time until the reinforcements finally arrive.",
    unitName = "MUDSHARK",
    duration = 12.0
  },
  [840] = {
    oggFile = "AUDIO/840.ogg",
    subtitle = "And those reinforcements still have to cross the Atlantic. Man… a few weeks ago I was just happy to be done with training. Now I’m in World War Three. This is not what I pictured.",
    unitName = "YOU",
    duration = 12.0
  },
  [841] = {
    oggFile = "AUDIO/841.ogg",
    subtitle = "Do you still get to talk to your folks back home? These last days?",
    unitName = "YOU",
    duration = 4.0
  },
  [842] = {
    oggFile = "AUDIO/742.ogg",
    subtitle = "Yeah… but never for long. We’ve kind of settled into a routine, one call a day, if we can make it work. It helps… you know, just hearing a familiar voice. My wife tries to sound calm when we talk… like everything’s fine back home. But I can hear it in her voice... she’s worried. I don’t really talk about the missions. No point in that. We just stick to normal things… everyday stuff. Keeps it… grounded, I guess. What about you?",
    unitName = "MUDSHARK",
    duration = 30.0
  },
  [843] = {
    oggFile = "AUDIO/843.ogg",
    subtitle = "No wife, no kids. My girlfriend’s still at university. Phone calls are hard to line up, so… I write letters. It’s kind of like a diary. I tell her what happened, what I’m thinking. Helps me process it before I try to sleep.",
    unitName = "YOU",
    duration = 14.0
  },
  [844] = {
    oggFile = "AUDIO/844.ogg",
    subtitle = "Yeah… everyone’s got their way. For me, it’s the normal talk that helps. It reminds me what we’re trying to protect. Gives me something solid to hold onto.",
    unitName = "MUDSHARK",
    duration = 10.0
  },
  [845] = {
    oggFile = "AUDIO/845.ogg",
    subtitle = "Yeah… well said.",
    unitName = "YOU",
    duration = 2.0
  },
  [846] = {
    oggFile = "AUDIO/846.ogg",
    subtitle = "Hawg Two, Magic. Weather is improving and we need your immidiate support at multiple prebriefed sectors. I need to split up your flight and will assign you to different killboxes. Standby for assignment.",
    unitName = "MAGIC",
    duration = 12.0
  },
  [847] = {
    oggFile = "AUDIO/847.ogg",
    subtitle = "Hawg Two One, your assigned Killbox is Delta. A spearhead of soviet mechaniezed troops have made their way thru the Taunus north of Frankfurt and reached the A3, they are advancing south now to flank our defenes around Frankfurt. Proceed to Killbox, search and destroy advancing enemy forces along the Autobahn 3.",
    unitName = "MAGIC",
    duration = 15.0
  },
  [848] = {
    oggFile = "AUDIO/848.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the north the killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [849] = {
    oggFile = "AUDIO/849.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the south of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [850] = {
    oggFile = "AUDIO/850.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [851] = {
    oggFile = "AUDIO/851.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [852] = {
    oggFile = "AUDIO/752.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the north east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [853] = {
    oggFile = "AUDIO/753.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the north west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [854] = {
    oggFile = "AUDIO/854.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the south east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [855] = {
    oggFile = "AUDIO/855.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the south west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [856] = {
    oggFile = "AUDIO/856.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Alpha. Targets spotted in the Center of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [857] = {
    oggFile = "AUDIO/857.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the north of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [858] = {
    oggFile = "AUDIO/858.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the south of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [859] = {
    oggFile = "AUDIO/859.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [860] = {
    oggFile = "AUDIO/760.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [861] = {
    oggFile = "AUDIO/861.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the north east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [862] = {
    oggFile = "AUDIO/862.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the north west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [863] = {
    oggFile = "AUDIO/863.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the south east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [864] = {
    oggFile = "AUDIO/864.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the south west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [865] = {
    oggFile = "AUDIO/865.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Bravo. Targets spotted in the Center of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [866] = {
    oggFile = "AUDIO/866.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the north of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [867] = {
    oggFile = "AUDIO/867.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the south of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [868] = {
    oggFile = "AUDIO/868.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [869] = {
    oggFile = "AUDIO/869.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [870] = {
    oggFile = "AUDIO/870.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the north east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [871] = {
    oggFile = "AUDIO/871.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the north west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [872] = {
    oggFile = "AUDIO/872.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the south east of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [873] = {
    oggFile = "AUDIO/873.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the south west of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [874] = {
    oggFile = "AUDIO/874.ogg",
    subtitle = "Hawg Two Two, Magic. Your assigned Killbox is Charlie. Targets spotted in the Center of your killbox. Enemy forces advancing along the roads, slow them down! You are cleared to engage at your discretion.",
    unitName = "MAGIC",
    duration = 13.0
  },
  [875] = {
    oggFile = "AUDIO/875.ogg",
    subtitle = "Wilco, proceeding to assigned killbox. Hawg Two Two.",
    unitName = "YOU",
    duration = 3.0
  },
  [876] = {
    oggFile = "AUDIO/876.ogg",
    subtitle = "Magic, Hawg Two Two. Approaching Killbox Alpha. Commencing search and destroy.",
    unitName = "YOU",
    duration = 5.0
  },
  [877] = {
    oggFile = "AUDIO/877.ogg",
    subtitle = "Magic, Hawg Two Two. Approaching Killbox Bravo. Commencing search and destroy.",
    unitName = "YOU",
    duration = 7.0
  },
  [878] = {
    oggFile = "AUDIO/878.ogg",
    subtitle = "Magic, Hawg Two Two. Approaching Killbox Charlie. Commencing search and destroy.",
    unitName = "YOU",
    duration = 7.0
  },
  [879] = {
    oggFile = "AUDIO/879.ogg",
    subtitle = "Hawg Two Two, Magic. Roger, continue. Monitor Magic for picture updates.",
    unitName = "MAGIC",
    duration = 7.0
  },
  [880] = {
    oggFile = "AUDIO/880.ogg",
    subtitle = "Wilco, Hawg Two Two.",
    unitName = "YOU",
    duration = 3.0
  },
  [881] = {
    oggFile = "AUDIO/881.ogg",
    subtitle = "Magic, Hawg Two One. Inbound Killbox Delta, searching for target.",
    unitName = "MUDSHARK",
    duration = 5.0
  },
  [882] = {
    oggFile = "AUDIO/882.ogg",
    subtitle = "Hawg Two One, Magic. Copy. Continue as fragged. Monitor Magic for picture updates.",
    unitName = "MAGIC",
    duration = 7.0
  },
  [883] = {
    oggFile = "AUDIO/883.ogg",
    subtitle = "Wilco, Hawg Two One.",
    unitName = "YOU",
    duration = 8.0
  },
  [884] = {
    oggFile = "AUDIO/444.ogg",
    subtitle = "Rockets away.",
    unitName = "YOU",
    duration = 3.0
  },
  [885] = {
    oggFile = "AUDIO/443.ogg",
    subtitle = "Guns, Guns, Guns.",
    unitName = "YOU",
    duration = 3.0
  },
  [886] = {
    oggFile = "AUDIO/442.ogg",
    subtitle = "Hawg Two Two, pickle!",
    unitName = "YOU",
    duration = 3.0
  },
  [887] = {
    oggFile = "AUDIO/441.ogg",
    subtitle = "Hawg Two Two, Rifle!",
    unitName = "YOU",
    duration = 3.0
  },
  [888] = {
    oggFile = "AUDIO/440.ogg",
    subtitle = "Hawg Two Two, Fox Two.",
    unitName = "YOU",
    duration = 3.0
  },
  [889] = {
    oggFile = "AUDIO/889.ogg",
    subtitle = "Magic, Hawg Two Two. All targets are down. Request RTB.",
    unitName = "YOU",
    duration = 6.0
  },
  [890] = {
    oggFile = "AUDIO/890.ogg",
    subtitle = "Hawg Two Two, Magic. Roger that, good job. Cleared RTB.",
    unitName = "MAGIC",
    duration = 6.0
  },
  [891] = {
    oggFile = "AUDIO/891.ogg",
    subtitle = "All flights, be advised. Enemy cruise and ballistic missile launch detected. Target area: Ramstein, Sembach, Kaiserslautern. Friendly air defense systems are active.",
    unitName = "MAGIC",
    duration = 12.0
  },
  [892] = {
    oggFile = "AUDIO/892.ogg",
    subtitle = "Hawg Two flight, Magic. Be advised, Sembach airfield is heavily damaged and no longer operational. Divert to emergency landing strip along the A61, near Sprendlingen. Contact local tower on 255.950 UHF for recovery.",
    unitName = "MAGIC",
    duration = 12.0
  },
  [893] = {
    oggFile = "AUDIO/893.ogg",
    subtitle = "Magic, Hawg Two One. Copy, diverting to A61 strip near Spendlingen. Local tower on 255.950.",
    unitName = "MAGIC",
    duration = 8.0
  },
  [894] = {
    oggFile = "AUDIO/894.ogg",
    subtitle = "Magic, Hawg Two Two, Wilco. Heading direct for divert Sprendlingen.",
    unitName = "MUDSHARK",
    duration = 8.0
  },
  [895] = {
    oggFile = "AUDIO/895.ogg",
    subtitle = "Hawg Two Two, Magic. Inbound for Sprendlingen remote runway, request to leave for local controller?",
    unitName = "YOU",
    duration = 8.0
  },
  [896] = {
    oggFile = "AUDIO/896.ogg",
    subtitle = "Hawg Two Two, cleared to leave.",
    unitName = "MAGIC",
    duration = 8.0
  },
  [897] = {
    oggFile = "AUDIO/897.ogg",
    subtitle = "Sprendlingen Control, this is Hawg Two Two. Single A-10 diverting to your airfield, requesting landing clearance.",
    unitName = "YOU",
    duration = 6.0
  },
  [898] = {
    oggFile = "AUDIO/898.ogg",
    subtitle = "Hawg Two Two, Sprendlingen. Proceed to entry point MAIN. From there, continue for runway One Six. Expect overhead break.",
    unitName = "SPRENDLINGEN",
    duration = 10.0
  },
  [899] = {
    oggFile = "AUDIO/899.ogg",
    subtitle = "Sprendlingen, Hawg Two Two. Roger. Entry point MAIN, runway One Six, overhead break.",
    unitName = "YOU",
    duration = 7.0
  },
  [8231] = {
    oggFile = "AUDIO/8231.ogg",
    subtitle = "Hawg Two copies, proceeding to holding.",
    unitName = "MUDSHARK",
    duration = 3.0
  },
}

local function playVoiceOver(voiceOver)
    local msg = "[" .. voiceOver.unitName .. "] " .. voiceOver.subtitle
    trigger.action.outSound(voiceOver.oggFile)
    trigger.action.outText(msg, voiceOver.duration)
end

function triggerVoiceOver(id)
    local voiceOver = voiceOvers[id]
    if voiceOver then
        playVoiceOver(voiceOver)
    else
        trigger.action.outText("Voice-Over ID " .. tostring(id) .. " nicht gefunden.", 10)
    end
end

trigger.action.outText("Voice Over System geladen – bereit für triggerVoiceOver(ID)", 5)