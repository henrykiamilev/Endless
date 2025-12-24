import Foundation
import Combine

/// AI Coach service with rule-based responses for golf coaching
class AICoachService: ObservableObject {
    static let shared = AICoachService()

    @Published var messages: [AICoachMessage] = []
    @Published var isTyping = false

    private var currentAnalysis: SwingAnalysisResult?

    private init() {
        // Add initial greeting
        addMessage(isUser: false, text: "Hi! I'm your AI Golf Coach. I can help you improve your swing based on video analysis. What would you like to work on?")
    }

    // MARK: - Public API

    /// Sets the current swing analysis context for more relevant responses
    func setAnalysisContext(_ analysis: SwingAnalysisResult?) {
        currentAnalysis = analysis

        if let analysis = analysis {
            // Add contextual greeting based on analysis
            let greeting = generateAnalysisGreeting(analysis)
            addMessage(isUser: false, text: greeting)
        }
    }

    /// Clears the conversation history
    func clearConversation() {
        messages = []
        addMessage(isUser: false, text: "Hi! I'm your AI Golf Coach. I can help you improve your swing based on video analysis. What would you like to work on?")
    }

    /// Sends a user message and generates a response
    func sendMessage(_ text: String) {
        // Add user message
        addMessage(isUser: true, text: text)

        // Generate response
        isTyping = true

        // Simulate typing delay for natural feel
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard let self = self else { return }

            let response = self.generateResponse(to: text)
            self.addMessage(isUser: false, text: response)
            self.isTyping = false
        }
    }

    // MARK: - Response Generation

    private func generateResponse(to question: String) -> String {
        let lowercased = question.lowercased()

        // Check for specific topics
        if containsAny(lowercased, keywords: ["grip", "hold", "hands"]) {
            return generateGripResponse()
        }

        if containsAny(lowercased, keywords: ["stance", "setup", "address", "position", "feet"]) {
            return generateStanceResponse()
        }

        if containsAny(lowercased, keywords: ["backswing", "back swing", "takeaway", "turn"]) {
            return generateBackswingResponse()
        }

        if containsAny(lowercased, keywords: ["downswing", "down swing", "transition", "lag"]) {
            return generateDownswingResponse()
        }

        if containsAny(lowercased, keywords: ["impact", "contact", "strike", "hit"]) {
            return generateImpactResponse()
        }

        if containsAny(lowercased, keywords: ["follow", "finish", "through"]) {
            return generateFollowThroughResponse()
        }

        if containsAny(lowercased, keywords: ["tempo", "rhythm", "speed", "timing"]) {
            return generateTempoResponse()
        }

        if containsAny(lowercased, keywords: ["slice", "hook", "fade", "draw", "curve"]) {
            return generateBallFlightResponse(question: lowercased)
        }

        if containsAny(lowercased, keywords: ["drill", "practice", "exercise", "work on"]) {
            return generateDrillResponse()
        }

        if containsAny(lowercased, keywords: ["score", "result", "analysis", "how did"]) {
            return generateScoreResponse()
        }

        if containsAny(lowercased, keywords: ["improve", "better", "help", "tip"]) {
            return generateImprovementResponse()
        }

        if containsAny(lowercased, keywords: ["yes", "sure", "ok", "please", "tell me more"]) {
            return generateFollowUpResponse()
        }

        // Default response
        return generateDefaultResponse()
    }

    private func containsAny(_ text: String, keywords: [String]) -> Bool {
        keywords.contains { text.contains($0) }
    }

    // MARK: - Topic-Specific Responses

    private func generateGripResponse() -> String {
        if let analysis = currentAnalysis,
           let gripScore = analysis.breakdown.first(where: { $0.phase == .grip }) {
            if gripScore.score >= 80 {
                return """
                Your grip looks solid at \(gripScore.score)/100! Here are some tips to maintain it:

                1. **Pressure**: Keep grip pressure at about 4/10 - firm enough to control the club, light enough to allow wrist hinge

                2. **Neutral position**: Check that you can see 2-2.5 knuckles on your lead hand at address

                3. **Connection**: Both hands should work as a unit - try the interlocking or overlapping grip if you haven't

                Would you like me to explain any of these in more detail?
                """
            } else {
                return """
                I noticed your grip could use some work (scored \(gripScore.score)/100). Let's focus on the fundamentals:

                1. **Lead hand first**: Place the club in your fingers, not your palm. The grip should run diagonally from the base of your pinky to mid-index finger

                2. **Trail hand**: Position it so the lifeline covers your lead thumb

                3. **Pressure check**: You're likely gripping too tight - try holding it like a tube of toothpaste without squeezing any out

                Try the \"grip pressure drill\" - make 10 swings focusing only on maintaining consistent pressure. How does that feel?
                """
            }
        }

        return """
        Great question about grip! The grip is your only connection to the club, so it's crucial. Here are the key points:

        1. **Neutral grip**: Both hands should work together. Check that the V's formed by your thumbs and forefingers point toward your trail shoulder

        2. **Pressure**: On a scale of 1-10, aim for about 4. Too tight restricts your wrist action

        3. **Consistency**: Your grip pressure should stay constant throughout the swing

        Would you like me to recommend some specific grip drills?
        """
    }

    private func generateStanceResponse() -> String {
        if let analysis = currentAnalysis,
           let stanceScore = analysis.breakdown.first(where: { $0.phase == .stance }) {
            if stanceScore.score >= 80 {
                return """
                Your stance is looking good at \(stanceScore.score)/100! Here's what you're doing well:

                - Good athletic posture
                - Weight balanced on balls of feet
                - Appropriate knee flex

                To maintain this, always do a quick \"stance check\" before each shot:
                1. Feet shoulder-width (for irons)
                2. Ball position appropriate for the club
                3. Spine tilted slightly away from target

                Is there a specific aspect of your setup you'd like to refine?
                """
            } else {
                return """
                Your stance scored \(stanceScore.score)/100 - let's work on improving it:

                **Key fixes:**
                1. **Width**: Feet should be shoulder-width for irons, slightly wider for driver
                2. **Weight distribution**: 50/50 between feet, on the balls of your feet (not heels or toes)
                3. **Knee flex**: Slight athletic bend - imagine you're about to jump

                **Quick drill**: Stand with your back against a wall, bend your knees slightly, then step forward into your stance. This helps you feel proper posture.

                Would you like me to explain ball position for different clubs?
                """
            }
        }

        return """
        Setup and stance are the foundation of a good swing! Here's what to focus on:

        **Posture:**
        - Bend from your hips, not your waist
        - Let your arms hang naturally
        - Chin up, eyes on the ball

        **Stance width:**
        - Driver: Feet outside shoulder width
        - Irons: Feet shoulder width
        - Wedges: Slightly narrower

        **Weight:**
        - Balanced on the balls of your feet
        - 50/50 distribution at address

        Would you like specific tips for your driver setup vs iron setup?
        """
    }

    private func generateBackswingResponse() -> String {
        if let analysis = currentAnalysis,
           let backswingScore = analysis.breakdown.first(where: { $0.phase == .backswing }) {
            return """
            Based on your analysis (\(backswingScore.score)/100 for backswing):

            \(backswingScore.score >= 80 ? "You're doing well! " : "Here's what to focus on: ")

            **Key checkpoints:**
            1. **Takeaway**: First 12 inches should be low and slow, club head outside hands
            2. **Shoulder turn**: Your back should face the target at the top
            3. **Maintain spine angle**: Don't lift up or dip down

            **Common fix:** If you're not completing your turn, try the \"back pocket drill\" - feel like you're putting your trail hand in your back pocket during the backswing.

            Would you like some backswing drills to practice?
            """
        }

        return """
        The backswing sets up everything that follows. Here are the essentials:

        1. **Start with your shoulders**: The takeaway should be initiated by your shoulders, not your hands

        2. **Full turn**: At the top, your back should face the target and your lead shoulder should be under your chin

        3. **Width**: Keep your arms extended (not locked) to create a wide arc

        4. **Weight shift**: Feel pressure build in your trail hip/leg

        **Top position checkpoint**: If you pause at the top, the club should be parallel to the ground and parallel to your target line.

        Want me to suggest some backswing drills?
        """
    }

    private func generateDownswingResponse() -> String {
        if let analysis = currentAnalysis,
           let downswingScore = analysis.breakdown.first(where: { $0.phase == .downswing }) {
            return """
            Your downswing scored \(downswingScore.score)/100. \(downswingScore.feedback)

            **The key to a good downswing is sequence:**
            1. Hips start first (bump toward target)
            2. Then torso rotates
            3. Arms drop into the \"slot\"
            4. Hands and club release last

            **Lag tip:** Think about keeping your back to the target as long as possible while your hips open. This creates that powerful \"lag\" position.

            **Drill:** Practice the \"pump drill\" - take the club to the top, then make 3 small downswing starts without hitting, feeling your hips initiate. Then hit the ball.

            Would you like more details on maintaining lag?
            """
        }

        return """
        The downswing is where power is generated! Here's the sequence:

        1. **Start from the ground up**: Weight shifts to lead foot, hips begin rotating toward target

        2. **Maintain lag**: Keep your wrist angle as long as possible - the club should feel like it's \"trailing\" behind

        3. **Stay connected**: Feel your arms staying close to your body as you rotate through

        **Power tip:** The feeling should be that your hands are \"dropping\" into the slot, not swinging out toward the ball.

        The ideal tempo ratio is 3:1 (backswing to downswing). Your downswing should be faster than your backswing, but not rushed.

        Shall I explain some lag drills?
        """
    }

    private func generateImpactResponse() -> String {
        if let analysis = currentAnalysis,
           let impactScore = analysis.breakdown.first(where: { $0.phase == .impact }) {
            return """
            Your impact position scored \(impactScore.score)/100. \(impactScore.feedback)

            **Ideal impact position:**
            - Hips open 30-40° to target
            - Shoulders nearly square
            - Hands ahead of ball (shaft leaning forward)
            - Weight mostly on lead foot

            **Key feel:** At impact, your belt buckle should be pointing slightly left of the ball (for right-handed golfers).

            **Impact bag drill:** Practice hitting an impact bag to feel proper hand position at contact. Focus on driving your hands toward the target.

            Would you like tips on compressing the ball better?
            """
        }

        return """
        Impact is the moment of truth! Here's what a good impact position looks like:

        **Body position:**
        - Hips open to target (30-40°)
        - Weight on lead foot (80%)
        - Head behind the ball

        **Club position:**
        - Shaft leaning forward (hands ahead of clubhead)
        - Clubface square to target
        - Slight divot AFTER the ball (with irons)

        **Key thought:** Don't try to \"hit\" at the ball. Swing THROUGH it. The ball just gets in the way of your swing.

        Want me to explain the impact bag drill?
        """
    }

    private func generateFollowThroughResponse() -> String {
        if let analysis = currentAnalysis,
           let followScore = analysis.breakdown.first(where: { $0.phase == .followThrough }) {
            return """
            Your follow-through scored \(followScore.score)/100. \(followScore.feedback)

            **A complete finish shows good swing mechanics:**
            - Belt buckle facing target
            - Weight fully on lead foot
            - Trail foot on toe (heel up)
            - Club over lead shoulder
            - Balanced enough to hold finish for 3 seconds

            **Extension drill:** After impact, feel like you're throwing the club toward the target (without actually letting go!). This promotes extension through the ball.

            **Tip:** If you can't hold your finish, it usually means something was off earlier in the swing.

            Would you like drills for better extension?
            """
        }

        return """
        The follow-through is the result of everything before it, but it's still important to have a target finish position:

        **Complete finish checklist:**
        - [ ] Belt buckle faces target
        - [ ] Weight on lead foot (almost all of it)
        - [ ] Trail heel fully off ground
        - [ ] Arms relaxed, club behind you
        - [ ] Balanced (can hold for 3 seconds)

        **Why it matters:** A good finish indicates good balance and rotation. If you're falling off balance, it often means swing path or tempo issues.

        **Practice tip:** Make swings focusing ONLY on a balanced finish. Don't worry about where the ball goes.

        Should I suggest some balance drills?
        """
    }

    private func generateTempoResponse() -> String {
        return """
        Tempo is one of the most underrated fundamentals! Here's how to improve it:

        **Ideal ratio:** 3:1 (backswing to downswing)
        - Count \"1-2-3\" during backswing
        - Count \"1\" during downswing

        **Tempo drills:**
        1. **Metronome practice**: Swing with a metronome at 60-72 BPM
        2. **Feet together**: Make swings with feet together - forces good tempo
        3. **Slow motion**: Make 5 ultra-slow swings, then gradually speed up

        **Common tempo mistake:** Rushing the transition at the top. Pause briefly at the top to feel the club \"set\" before starting down.

        **Pro tip:** Watch videos of Fred Couples or Ernie Els for tempo inspiration. Their swings look effortless because their tempo is perfect.

        Would you like specific metronome settings to practice with?
        """
    }

    private func generateBallFlightResponse(question: String) -> String {
        if question.contains("slice") {
            return """
            A slice typically comes from an open clubface at impact or an out-to-in swing path (or both). Here's how to fix it:

            **Quick fixes:**
            1. **Strengthen your grip**: Rotate both hands slightly to the right (for right-handers)
            2. **Check your alignment**: You might be aimed left, causing an out-to-in path
            3. **Close the face**: Feel like you're turning the toe over through impact

            **Drill:** Place a headcover outside the ball. If you hit it, you're swinging out-to-in. Practice swinging \"inside-out\" to miss the headcover.

            **Path check:** Put an alignment stick 2 feet in front of the ball, angled right. Try to start the ball right of the stick.

            Want me to explain the grip changes in more detail?
            """
        } else if question.contains("hook") {
            return """
            A hook comes from a closed clubface or an in-to-out path. Here's how to correct it:

            **Adjustments:**
            1. **Weaken your grip**: Rotate both hands slightly left (for right-handers)
            2. **Check ball position**: It might be too far back
            3. **Body rotation**: Make sure you're rotating through, not hanging back

            **Drill:** Practice hitting punch shots with less hand action. Feel like the clubface stays square longer through impact.

            **Thought:** Focus on \"covering\" the ball with your chest through impact rather than flipping your hands.

            Would you like more details on grip adjustments?
            """
        }

        return """
        Ball flight is determined by two factors: **clubface angle** and **swing path**.

        **The new ball flight laws:**
        - Ball starts where the face points
        - Ball curves away from the path

        **To hit a draw (curves right to left for righties):**
        - Path slightly in-to-out
        - Face closed to path but open to target

        **To hit a fade (curves left to right for righties):**
        - Path slightly out-to-in
        - Face open to path but closed to target

        What specific ball flight issue are you dealing with?
        """
    }

    private func generateDrillResponse() -> String {
        if let analysis = currentAnalysis {
            // Find the weakest area
            let weakest = analysis.breakdown.min { $0.score < $1.score }

            if let weakPhase = weakest {
                let drill = analysis.drills.first { $0.targetPhase == weakPhase.phase }
                    ?? generateDrillFor(phase: weakPhase.phase)

                return """
                Based on your analysis, I'd focus on your \(weakPhase.phase.rawValue.lowercased()) (scored \(weakPhase.score)/100).

                **Recommended drill: \(drill.title)**
                Duration: \(drill.duration)

                \(drill.description)

                **How to practice:**
                1. Start with slow, exaggerated movements
                2. Gradually increase speed as the motion becomes natural
                3. Do 3 sets of 10 reps

                Would you like drills for other areas too?
                """
            }
        }

        return """
        Here are my top 5 drills for any golfer:

        1. **Feet together drill** (Tempo & Balance)
           Hit balls with feet together - improves tempo and balance

        2. **Alignment stick gate** (Path)
           Place two sticks creating a gate to swing through

        3. **Impact bag work** (Impact position)
           Hit an impact bag to feel proper hand position

        4. **Pause at the top** (Transition)
           Pause for 1 second at the top of your backswing

        5. **9-to-3 drill** (Contact)
           Make half swings focusing on solid contact

        Which drill would you like me to explain in detail?
        """
    }

    private func generateDrillFor(phase: SwingPhase) -> RecommendedDrill {
        switch phase {
        case .grip:
            return RecommendedDrill(title: "Grip Pressure Drill", duration: "10 min",
                                    description: "Practice gripping at 4/10 pressure and maintaining it throughout the swing",
                                    targetPhase: .grip)
        case .stance:
            return RecommendedDrill(title: "Wall Posture Drill", duration: "5 min",
                                    description: "Stand with back against wall, bend knees, then step into address position",
                                    targetPhase: .stance)
        case .backswing:
            return RecommendedDrill(title: "Turn Drill", duration: "10 min",
                                    description: "Practice shoulder turn with club across shoulders, back facing target at top",
                                    targetPhase: .backswing)
        case .downswing:
            return RecommendedDrill(title: "Pump Drill", duration: "15 min",
                                    description: "Make 3 small downswing starts, feeling hips initiate, before completing swing",
                                    targetPhase: .downswing)
        case .impact:
            return RecommendedDrill(title: "Impact Bag Training", duration: "15 min",
                                    description: "Hit impact bag focusing on hands ahead and forward shaft lean",
                                    targetPhase: .impact)
        case .followThrough:
            return RecommendedDrill(title: "Finish & Hold", duration: "10 min",
                                    description: "Make swings holding balanced finish for 3 seconds on every shot",
                                    targetPhase: .followThrough)
        }
    }

    private func generateScoreResponse() -> String {
        if let analysis = currentAnalysis {
            let best = analysis.breakdown.max { $0.score < $1.score }
            let worst = analysis.breakdown.min { $0.score < $1.score }

            return """
            Here's a summary of your swing analysis:

            **Overall Score: \(analysis.overallScore)/100**\(analysis.improvement.map { $0 > 0 ? " (+\($0) improvement!)" : "" } ?? "")

            **Your strengths:**
            - \(best?.phase.rawValue ?? "N/A"): \(best?.score ?? 0)/100 - \(best?.feedback ?? "")

            **Area to focus on:**
            - \(worst?.phase.rawValue ?? "N/A"): \(worst?.score ?? 0)/100 - \(worst?.feedback ?? "")

            **Breakdown:**
            \(analysis.breakdown.map { "• \($0.phase.rawValue): \($0.score)/100" }.joined(separator: "\n"))

            Would you like specific tips for improving your \(worst?.phase.rawValue.lowercased() ?? "swing")?
            """
        }

        return "I don't have a swing analysis loaded. Try analyzing a video first, then ask me about the results!"
    }

    private func generateImprovementResponse() -> String {
        if let analysis = currentAnalysis {
            // Find top 2 areas to improve
            let sorted = analysis.breakdown.sorted { $0.score < $1.score }
            let areasToFocus = sorted.prefix(2)

            return """
            Based on your swing analysis, here are my top recommendations:

            **Priority 1: \(areasToFocus.first?.phase.rawValue ?? "N/A")** (Score: \(areasToFocus.first?.score ?? 0)/100)
            \(analysis.tips.first?.description ?? "Focus on the fundamentals here.")

            **Priority 2: \(areasToFocus.last?.phase.rawValue ?? "N/A")** (Score: \(areasToFocus.last?.score ?? 0)/100)
            \(analysis.tips.dropFirst().first?.description ?? "Keep working on this area.")

            **Practice plan:**
            1. Spend 60% of your practice on Priority 1
            2. Spend 30% on Priority 2
            3. Use 10% for full swings integrating both

            Would you like specific drills for either of these areas?
            """
        }

        return """
        To improve your golf swing, focus on these fundamentals:

        1. **Grip**: Your only connection to the club
        2. **Setup**: A good stance makes everything easier
        3. **Tempo**: Smooth and controlled beats fast and jerky
        4. **Balance**: Finish in a balanced position every time

        For the fastest improvement, I'd recommend recording your swing and getting it analyzed. Then we can give you specific feedback!

        What aspect would you like to work on first?
        """
    }

    private func generateFollowUpResponse() -> String {
        // Provide additional detail based on recent conversation
        if let lastAIMessage = messages.filter({ !$0.isUser }).last {
            if lastAIMessage.text.contains("grip") {
                return """
                Here's more detail on grip:

                **The Perfect Grip Process:**
                1. Hold the club in your fingers of the lead hand (left hand for righties)
                2. The club should run from the base of your pinky to the middle of your index finger
                3. Wrap your fingers around - you should see 2-2.5 knuckles looking down
                4. Place trail hand so the lifeline covers the lead thumb
                5. Trail pinky either overlaps or interlocks with lead hand

                **Pressure points:** Feel most pressure in the last three fingers of your lead hand and the middle two fingers of your trail hand.

                Ready to try it?
                """
            }
        }

        return """
        Let me give you some additional pointers:

        **The 80/20 of golf improvement:**
        - 80% of improvement comes from:
          • Consistent setup routine
          • Solid grip fundamentals
          • Good tempo
          • Balanced finish

        - Only 20% comes from technical swing positions

        **Quick wins:**
        1. Practice your pre-shot routine until it's automatic
        2. Use alignment sticks every practice session
        3. Film your swing weekly to track progress

        What specific area should we dive deeper into?
        """
    }

    private func generateDefaultResponse() -> String {
        let responses = [
            "That's a great question! Could you be more specific about what aspect of your swing you'd like to work on? I can help with grip, stance, backswing, downswing, impact, or follow-through.",

            "I'd be happy to help with that. What part of your game would you like to focus on - full swing, short game, or something specific from your analysis?",

            "Good question! To give you the best advice, could you tell me what you're struggling with most - is it distance, accuracy, or consistency?",

            "I can help with that! Are you looking for technical tips, practice drills, or an explanation of your swing analysis?",
        ]

        return responses.randomElement() ?? responses[0]
    }

    private func generateAnalysisGreeting(_ analysis: SwingAnalysisResult) -> String {
        let best = analysis.breakdown.max { $0.score < $1.score }
        let worst = analysis.breakdown.min { $0.score < $1.score }

        return """
        I've reviewed your swing analysis! Your overall score is \(analysis.overallScore)/100.

        **Great work on your \(best?.phase.rawValue.lowercased() ?? "swing")!** - That's your strongest area at \(best?.score ?? 0)/100.

        I'd suggest focusing on your **\(worst?.phase.rawValue.lowercased() ?? "swing")** - that's where you have the most room for improvement at \(worst?.score ?? 0)/100.

        What would you like to work on first?
        """
    }

    // MARK: - Helpers

    private func addMessage(isUser: Bool, text: String) {
        let message = AICoachMessage(isUser: isUser, text: text)
        messages.append(message)
    }
}
