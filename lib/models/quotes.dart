// Theme Name -> List of Quotes
const Map<String, List<String>> themeQuotes = {

  // 1. FloraBlush Garden 🌺
  'FloraBlush Garden': [
    "Bloom where you are planted. 🌸",
    "Nature does not hurry, yet everything is accomplished. — Lao Tzu",
    "Adopt the pace of nature: her secret is patience. — Emerson",
    "Every flower must grow through dirt.",
    "Softly, steadily, you are becoming.",
    "What you water grows.",
    "Let your ideas take root.",
    "Small steps still move mountains.",
    "The earth laughs in flowers. — Emerson",
    "Growth is quiet but unstoppable.",
    "Even the tallest oak began as a seed.",
    "Flourish in your own season.",
  ],

  // 2. Rustic Meridian 🌾
  'Rustic Meridian': [
    "Hard work yields the best harvest. 🌾",
    "Well done is better than well said. — Benjamin Franklin",
    "Slow and steady wins the race.",
    "No masterpiece was ever built in comfort.",
    "Simplicity is the ultimate sophistication. — Leonardo da Vinci",
    "Discipline is choosing between what you want now and what you want most.",
    "The grind shapes the grain.",
    "Stay humble. Stay hungry.",
    "A good day’s work feeds the soul.",
    "Every task is a seed sown for tomorrow.",
    "Fortune favors the bold. — Virgil",
    "Build with your hands. Dream with your mind.",
  ],

  // 3. Crimson Horizon 🌇
  'Crimson Horizon': [
    "The sun sets to rise again. ☀️",
    "What we achieve inwardly will change outer reality. — Plutarch",
    "Passion fuels the journey.",
    "Burn with purpose.",
    "The future belongs to the brave.",
    "Difficult roads often lead to beautiful destinations.",
    "He who has a why can bear almost any how. — Nietzsche",
    "Chase the horizon.",
    "End the day stronger than you started.",
    "Energy and persistence conquer all things. — Benjamin Franklin",
    "Rise, even when the sky burns.",
    "Victory loves preparation.",
  ],

  // 4. Nocturne Tide 🌙
  'Nocturne Tide': [
    "Silence speaks volumes. 🌙",
    "The quieter you become, the more you can hear. — Ram Dass",
    "Deep focus, like the ocean depths.",
    "Still waters run deep.",
    "Rest is part of the rhythm.",
    "Calm mind. Sharp execution.",
    "In the depth of winter, I found an invincible summer. — Camus",
    "Peace begins with a single breath.",
    "The night sharpens clarity.",
    "Solitude strengthens resolve.",
    "Master your mind, master your world.",
    "Focus is a superpower.",
  ],

  // 5. Velvet Roast ☕
  'Velvet Roast': [
    "Life begins after coffee. ☕",
    "Grind now, shine later.",
    "Stay grounded.",
    "Success brews daily.",
    "The only limit is the one you set yourself.",
    "Work hard in silence; let success make the noise. — Frank Ocean",
    "Warmth in every accomplishment.",
    "Focus is brewed in discipline.",
    "Ambition tastes better earned.",
    "Great things are done by a series of small things brought together. — Van Gogh",
    "Sip. Focus. Execute.",
    "Strong mind. Strong finish.",
  ],

  // 6. Imperial Blush 🌹
  'Imperial Blush': [
    "Elegance in every action. 🌹",
    "Grace under pressure.",
    "Your potential is sovereign.",
    "Dignity is silent strength.",
    "Act as if what you do makes a difference. It does. — William James",
    "Excellence is not an act but a habit. — Aristotle",
    "Command your time.",
    "Poise is power.",
    "Rule yourself first.",
    "Refinement requires restraint.",
    "Confidence without arrogance.",
    "Carry yourself like royalty.",
  ],

  // 7. Verdant Empress 👑
  'Verdant Empress': [
    "Growth is the only evidence of life. — John Henry Newman",
    "A queen does not rush.",
    "Cultivate your empire.",
    "Prosperity follows focus.",
    "Lead with quiet strength.",
    "She remembered who she was and the game changed.",
    "Invest in yourself.",
    "Nurture what matters.",
    "Power is patience in motion.",
    "Stand tall, grow deeper.",
    "The throne is earned.",
    "Command with kindness.",
  ],

  // 8. Solar Marina 🌊
  'Solar Marina': [
    "Ride the wave of productivity. 🌊",
    "Flow like water. — Bruce Lee",
    "Energy is contagious.",
    "Sunshine fuels momentum.",
    "Bright minds shine brighter.",
    "Happiness depends upon ourselves. — Aristotle",
    "Momentum builds mastery.",
    "Stay radiant.",
    "A rising tide lifts all boats.",
    "Light conquers shadow.",
    "Move with purpose.",
    "Shine without apology.",
  ],

  // 9. Arctic Dominion ❄️
  'Arctic Dominion': [
    "Cool head, warm heart. ❄️",
    "Precision is power.",
    "Stay frosty.",
    "What gets measured gets improved. — Peter Drucker",
    "Crystal clear focus.",
    "Discipline equals freedom. — Jocko Willink",
    "Calm is a weapon.",
    "Execute without noise.",
    "Efficiency is elegance.",
    "Sharp mind. Steady hand.",
    "No chaos. Only clarity.",
    "Cold focus. Hot results.",
  ],

  // 10. Nebula Regent 🚀
  'Nebula Regent': [
    "The universe is yours to explore. 🚀",
    "Shoot for the moon. Even if you miss, you'll land among the stars. — Norman Vincent Peale",
    "To infinity and beyond.",
    "Infinite possibilities.",
    "Somewhere, something incredible is waiting to be known. — Carl Sagan",
    "Dream beyond gravity.",
    "Exploration begins with curiosity.",
    "Your limits are illusions.",
    "The stars reward the bold.",
    "Create your own orbit.",
    "Cosmic ambition.",
    "Dare greatly. — Theodore Roosevelt",
  ],

  // 11. Harvest Sovereign 🌾
  'Harvest Sovereign': [
    "Reap what you sow. 🌾",
    "Patience plants the strongest roots.",
    "Abundance awaits.",
    "Trust the process.",
    "The future depends on what you do today. — Gandhi",
    "Small efforts compound.",
    "Golden fields of opportunity.",
    "Work with the seasons.",
    "Preparation meets opportunity.",
    "Consistency is wealth.",
    "The harvest rewards discipline.",
    "Earn your abundance.",
  ],

  // 12. Pearl Meridian 🦪
  'Pearl Meridian': [
    "Wisdom comes with time. 🦪",
    "Polished by pressure.",
    "Beauty in the details.",
    "Stillness refines thought.",
    "Perfection is achieved not when there is nothing more to add, but when nothing more can be taken away. — Antoine de Saint-Exupéry",
    "A hidden gem of focus.",
    "Refinement requires patience.",
    "Clarity is rare and precious.",
    "Simplicity reveals brilliance.",
    "Depth over noise.",
    "Quiet luxury.",
    "Precious moments of clarity.",
  ],

  // 13. Neon Dominion ⚡
  'Neon Dominion': [
    "System Online. Focus: 100%. ⚡",
    "High voltage productivity.",
    "Code. Execute. Repeat.",
    "Innovation distinguishes between a leader and a follower. — Steve Jobs",
    "Neon dreams, electric reality.",
    "Power up.",
    "Adapt. Upgrade. Dominate.",
    "Think different.",
    "Velocity matters.",
    "Break the pattern.",
    "Precision meets speed.",
    "Future loading...",
  ],

  // 14. Velour Machine 🏎️
  'Velour Machine': [
    "Full throttle. 🏎️",
    "Drive your ambition.",
    "Luxury is earned.",
    "Speed with control.",
    "Excellence is engineered.",
    "Winners focus on winning.",
    "Smooth ride to success.",
    "Performance over noise.",
    "Fuel your fire.",
    "Class never goes out of style.",
    "Engineered for greatness.",
    "Pedal to purpose.",
  ],

  // 15. Monarch Noir 🧥
  'Monarch Noir': [
    "Power in silence. 🧥",
    "Mastery is quiet.",
    "Checkmate.",
    "He who conquers himself is the mightiest warrior. — Confucius",
    "Absolute control.",
    "Darkness reveals the light.",
    "Confidence needs no announcement.",
    "Silence is strategy.",
    "Calm dominance.",
    "The crown is heavy for a reason.",
    "Precision. Patience. Power.",
    "Own the board.",
  ],

  // 16. Imperial Inferno 🔥
  'Imperial Inferno': [
    "Burn bright. 🔥",
    "Victory is the only option.",
    "Fortune favors the bold. — Virgil",
    "Forged in fire.",
    "Relentless pursuit.",
    "The harder the battle, the sweeter the victory.",
    "Courage is resistance to fear. — Mark Twain",
    "Unstoppable force.",
    "Fuel the fire within.",
    "No retreat. No surrender.",
    "Intensity creates impact.",
    "Rise through the flames.",
  ],

};
