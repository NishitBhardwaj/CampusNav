/// CampusNav - AI Design Documentation
///
/// This document explains the AI design decisions for CampusNav.
/// Intended for hackathon judges and future developers.
///
/// ============================================================================
/// WHY WE DON'T USE REINFORCEMENT LEARNING
/// ============================================================================
///
/// Many modern AI systems use Reinforcement Learning (RL) to improve based on
/// user behavior. We explicitly chose NOT to use RL for the following reasons:
///
/// 1. DATA INTEGRITY
///    - Campus data (room numbers, personnel locations) must be 100% accurate
///    - RL learns from patterns, which could reinforce errors
///    - If many users search for "Registrar" and find "Room 101", RL might
///      start returning Room 101 for all similar queries, even if wrong
///
/// 2. TRANSPARENCY & AUDITABILITY
///    - Our fuzzy matching algorithm is deterministic and explainable
///    - Given the same input, we always get the same output
///    - Admins can understand exactly why a search result was returned
///    - RL models are often "black boxes" that are hard to audit
///
/// 3. OFFLINE-FIRST DESIGN
///    - RL typically requires significant computation for training
///    - Our approach works instantly on any device, even low-end Android
///    - No training phase needed - works immediately after install
///
/// 4. TRUST & RELIABILITY
///    - Users trust that "Room 204" is actually Room 204
///    - We don't want AI to "hallucinate" information
///    - All data returned is admin-verified and timestamped
///
/// 5. HACKATHON APPROPRIATENESS
///    - RL requires extensive training data we don't have
///    - Simpler approaches often work better for structured data
///    - We can demonstrate working functionality immediately
///
/// ============================================================================
/// WHAT WE USE INSTEAD: HUMAN-IN-THE-LOOP LEARNING
/// ============================================================================
///
/// Instead of autonomous learning, we implement supervised refinement:
///
/// 1. USER FEEDBACK COLLECTION
///    - Every search result shows "Is this information correct? (Yes/No)"
///    - Users can report inaccuracies with optional comments
///    - Feedback is stored locally, NOT auto-applied
///
/// 2. ADMIN VERIFICATION
///    - Feedback enters a review queue
///    - Admins see what users reported and can approve or dismiss
///    - Only approved changes update the actual data
///
/// 3. EXPLICIT DATA UPDATES
///    - When admin approves feedback, we update the source data
///    - This is NOT "learning" - it's controlled data correction
///    - Full audit trail maintained (who, what, when)
///
/// 4. SEARCH INDEX REFRESH
///    - After data updates, search index is rebuilt
///    - New searches reflect approved corrections
///    - Users see "Last verified" timestamps for transparency
///
/// ============================================================================
/// OUR AI SEARCH ALGORITHM
/// ============================================================================
///
/// We use a hybrid approach combining:
///
/// 1. EXACT MATCHING
///    - Direct string match on room numbers, names
///    - Highest confidence, fastest performance
///
/// 2. FUZZY MATCHING (Levenshtein Distance)
///    - Handles typos and partial matches
///    - "Dr. Kumar" matches "Dr. Rajesh Kumar"
///    - Normalized to 0-1 score
///
/// 3. INTENT DETECTION
///    - Keyword-based detection (not ML-based)
///    - Recognizes patterns like "Dr.", "Prof.", "Room"
///    - Filters results appropriately
///
/// 4. SYNONYM EXPANSION
///    - "restroom" → ["bathroom", "toilet", "washroom"]
///    - Improves recall for common terms
///    - Synonyms are curated, not learned
///
/// 5. RELEVANCE RANKING
///    - Exact matches score highest
///    - Keyword matches score moderately
///    - Fuzzy matches score lower
///    - Results sorted by score
///
/// ============================================================================
/// PERFORMANCE GUARANTEES
/// ============================================================================
///
/// - All searches complete in <300ms on target devices
/// - Works completely offline
/// - No network requests for search functionality
/// - Memory-efficient for low-end devices
///
/// ============================================================================
/// ETHICAL CONSIDERATIONS
/// ============================================================================
///
/// 1. NO HALLUCINATION
///    - We only return admin-verified data
///    - "I don't know" is better than a wrong answer
///
/// 2. DATA FRESHNESS VISIBILITY
///    - All results show "Last verified" date
///    - Users can judge data currency
///
/// 3. FEEDBACK TRANSPARENCY
///    - Users know their feedback goes to admins
///    - Not used for any automatic changes
///
/// 4. PRIVACY
///    - No user tracking
///    - No behavioral analytics
///    - Feedback is anonymous by default
///
/// ============================================================================

// This file is documentation-only and does not contain executable code.
// See offline_ai_search.dart for the actual implementation.
