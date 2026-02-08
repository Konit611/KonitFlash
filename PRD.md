# KonitFlash — Product Requirements Document (PRD)

> **Version:** 1.0
> **Last Updated:** 2026-02-09
> **Status:** Draft

---

## 1. Product Vision

KonitFlash는 **Anki 스타일의 간격 반복(Spaced Repetition)** 플래시카드 학습 앱입니다.
사용자가 직접 카드를 만들거나 **NotebookLM CSV 파일을 임포트**하여 덱을 구성하고,
SM-2 기반 알고리즘으로 최적의 복습 시점에 카드를 다시 제시합니다.
**iCloud를 통해 iPhone과 Mac 간 학습 데이터가 자동 동기화**됩니다.

---

## 2. Current State Analysis (As-Is)

### 2.1 구현 완료 (✅)

| 영역 | 상태 | 세부 |
|------|------|------|
| **UI/Design System** | ✅ 완료 | 6개 화면 (Home, DeckDetail, AddDeck, AddCard, FlashCard, Settings) + 14개 재사용 컴포넌트 |
| **반응형 레이아웃** | ✅ 완료 | `horizontalSizeClass` 기반 iPhone/iPad(Mac) 분기 |
| **네비게이션** | ✅ 완료 | NavigationStack + NavigationRoute enum (7개 라우트) |
| **다국어 지원** | ✅ 완료 | 4개 언어 (en, ko, ja, zh-Hans) + 런타임 전환 |
| **VIP 아키텍처** | ✅ 완료 | 모든 Scene에 View/Interactor/Presenter 분리 |
| **3D 카드 플립** | ✅ 완료 | rotation3DEffect + 레이아웃 점프 방지 |
| **학습 결과 화면** | ✅ 완료 | 정답률 링 + 통계 그리드 |

### 2.2 스텁/부분 구현 (⚠️)

| 영역 | 상태 | 세부 |
|------|------|------|
| **덱/카드 CRUD 폼** | ⚠️ UI만 | 폼 유효성 검사 동작, 저장은 no-op (TODO 주석) |
| **삭제** | ⚠️ 인메모리 | viewState에서만 제거, 재시작 시 복원 |
| **간격 표시** | ⚠️ 라벨만 | Again/Hard/Good/Easy 버튼에 텍스트만 표시, 실제 스케줄링 없음 |
| **iCloud** | ⚠️ 엔타이틀먼트만 | CloudKit capability ON, 컨테이너 ID 미설정, 코드 없음 |

### 2.3 미구현 (❌)

| 영역 | 상태 |
|------|------|
| **데이터 영속성** | ❌ SwiftData/CoreData 없음, 모든 데이터가 하드코딩 샘플 |
| **간격 반복 알고리즘** | ❌ SM-2/Leitner 없음 |
| **CSV 임포트** | ❌ 파일 처리 코드 없음 |
| **iCloud 동기화** | ❌ CloudKit 코드 없음 |
| **유닛 테스트** | ❌ 빈 템플릿만 존재 |
| **빈 상태(Empty State) UI** | ❌ 덱이 없을 때의 화면 없음 |
| **검색/필터** | ❌ |
| **온보딩** | ❌ |

---

## 3. Target Users

| 페르소나 | 설명 |
|---------|------|
| **학생** | 시험 준비를 위해 단어/개념을 반복 학습하는 대학생 |
| **어학 학습자** | 영어/일본어/중국어 어휘를 간격 반복으로 암기하는 직장인 |
| **지식 노동자** | NotebookLM으로 정리한 학습 자료를 플래시카드로 변환하여 복습하는 사용자 |

---

## 4. Feature Requirements

### Phase 1: Data Foundation (데이터 기반)

> **목표:** 하드코딩 샘플 데이터를 SwiftData 기반 실제 영속성으로 교체

#### F1.1 SwiftData 모델 정의
- **Deck 모델** (`@Model`)
  - `id: UUID`, `name: String`, `deckDescription: String`, `colorTag: String`
  - `createdAt: Date`, `updatedAt: Date`
  - `cards: [Card]` (1:N 관계)
  - Computed: `totalCards`, `dueCards`, `progress`, `estimatedMinutes`
- **Card 모델** (`@Model`)
  - `id: UUID`, `front: String`, `back: String`
  - `deck: Deck` (역관계)
  - `createdAt: Date`, `updatedAt: Date`
  - SRS 필드: `dueDate: Date`, `interval: Double` (일 단위), `easeFactor: Double` (기본 2.5), `repetitions: Int`, `box: Int`
- **StudyLog 모델** (`@Model`) — 학습 기록
  - `id: UUID`, `card: Card`, `grade: Int` (0-3), `studiedAt: Date`, `elapsedSeconds: Double`
- **ModelContainer** 설정: `KonitFlashApp`에서 `.modelContainer(for:)` 추가

#### F1.2 실제 CRUD 구현
- `AddDeckInteractor`: `saveDeck()`, `updateDeck()`, `deleteDeck()` → ModelContext 연동
- `AddCardInteractor`: `saveCard()`, `updateCard()`, `deleteCard()` → ModelContext 연동
- `HomeInteractor`: `fetchHomeData()` → `@Query` 또는 `FetchDescriptor`로 실제 덱 목록 조회
- `DeckDetailInteractor`: `fetchDeckDetail(deckID:)` → 특정 덱의 카드 목록 조회
- 삭제 시 `.confirmationDialog` 유지 + ModelContext에서 실제 삭제

#### F1.3 Empty State UI
- 덱이 0개일 때: "첫 번째 덱을 만들어보세요" + CTA 버튼
- 카드가 0개일 때: "카드를 추가하세요" + CTA 버튼
- 복습할 카드가 0개일 때: "오늘의 학습을 모두 완료했습니다" 메시지

#### F1.4 실제 통계 계산
- `HomeStats`: StudyLog 기반으로 streak, learned, reviews, overdue 계산
- `DayActivity`: 최근 7일 학습 활동 집계
- DeckDetail: NEW (미학습) / LEARNING (학습중) / REVIEWED (복습완료) 실제 카운트

---

### Phase 2: Spaced Repetition System (간격 반복 알고리즘)

> **목표:** SM-2 알고리즘 기반의 실제 카드 스케줄링 구현

#### F2.1 SM-2 알고리즘 구현
- **위치:** `FlashCardInteractor` 내부 또는 별도 `SRSEngine` (Models/)
- **입력:** 현재 카드 상태 (interval, easeFactor, repetitions) + 사용자 등급 (AnswerGrade)
- **출력:** 새로운 interval, easeFactor, repetitions, dueDate
- **등급 매핑:**
  - Again (0): interval = 1분, repetitions 리셋
  - Hard (1): interval × 1.2, easeFactor 감소
  - Good (2): interval × easeFactor
  - Easy (3): interval × easeFactor × 1.3, easeFactor 증가
- **easeFactor 범위:** 최소 1.3 (과도한 감소 방지)
- **새 카드 첫 학습:** interval = 10분 → 1일 → SM-2 적용

#### F2.2 학습 세션 로직
- `FlashCardInteractor.fetchStudySession(deckID:)`:
  - `dueDate <= now` 인 카드를 `dueDate` 오름차순으로 조회
  - 최대 세션 크기 제한 (기본 20장, 설정 가능)
  - 새 카드 / 복습 카드 혼합 비율 설정
- `FlashCardInteractor.recordAnswer()`:
  - SM-2 계산 → Card 업데이트 (interval, easeFactor, repetitions, dueDate)
  - StudyLog 생성
  - ModelContext 저장

#### F2.3 학습 통계
- 세션 종료 시: 실제 StudyLog 기반 결과 표시
- Home 화면: 오늘/이번 주 학습량, 연속 학습일(streak), 예정 복습 수

#### F2.4 Overdue 배너 연동
- "Catch Up Now" 버튼: overdue 카드가 있는 첫 번째 덱의 FlashCard로 이동
- overdue 카운트: `dueDate < today` 인 전체 카드 수

---

### Phase 3: CSV Import (NotebookLM 연동)

> **목표:** NotebookLM에서 내보낸 CSV 파일을 임포트하여 덱에 카드 추가

#### F3.1 CSV 파서
- **위치:** `Models/CSVParser.swift` 또는 `Services/CSVImporter.swift`
- **지원 포맷:**
  - 2열 CSV: `front,back` (헤더 유무 자동 감지)
  - TSV (탭 구분) 지원
  - UTF-8 인코딩 필수
  - 따옴표 이스케이프 처리 (`"he said ""hello"""`)
- **에러 처리:**
  - 빈 행 스킵
  - 열 수 불일치 시 경고 + 스킵
  - 파싱 결과 미리보기 (총 N장, 스킵 M장)

#### F3.2 임포트 UI
- **진입점 1:** AddDeck 화면에서 "CSV에서 임포트" 버튼
  - 새 덱 생성 + CSV 카드 일괄 추가
- **진입점 2:** DeckDetail 화면에서 "CSV 임포트" 버튼
  - 기존 덱에 CSV 카드 추가
- **플로우:**
  1. `.fileImporter` 시트 → CSV/TSV 파일 선택
  2. 파싱 + 미리보기 (처음 5장 표시, 총 카드 수)
  3. "임포트" 확인 → 카드 생성 → 덱으로 이동
- **UniformType:** `.commaSeparatedText`, `.tabSeparatedText`, `.plainText`

#### F3.3 NotebookLM 특화
- NotebookLM 기본 내보내기 포맷 대응:
  - 첫 행이 헤더("Term", "Definition" 등)인 경우 자동 스킵
  - BOM (Byte Order Mark) 처리
- 임포트 시 중복 카드 감지 (동일 front 텍스트 경고)

---

### Phase 4: iCloud Sync (클라우드 동기화)

> **목표:** iPhone ↔ Mac 간 학습 데이터 실시간 동기화

#### F4.1 SwiftData + CloudKit 통합
- **접근:** SwiftData의 CloudKit 자동 동기화 활용
  - `ModelConfiguration(cloudKitDatabase: .automatic)`
  - 별도 CloudKit 코드 최소화
- **iCloud 컨테이너:** `iCloud.geunil.KonitFlash`
- **동기화 대상:** Deck, Card, StudyLog 전체
- **제약사항:**
  - SwiftData CloudKit은 `unique` 제약 미지원 → 앱 레벨 중복 처리
  - Optional 속성 또는 기본값 필수 (CloudKit 요구사항)
  - 관계(Relationship)는 CloudKit에서 자동 처리

#### F4.2 충돌 해결
- **전략:** Last-Writer-Wins (마지막 수정 우선)
- `updatedAt` 필드 기반 최신 데이터 유지
- 카드 SRS 상태 충돌: 더 최근 `studiedAt`의 StudyLog 기준

#### F4.3 오프라인 지원
- 오프라인에서 정상 학습 가능 (로컬 SwiftData)
- 네트워크 복구 시 자동 동기화
- 동기화 상태 표시: Settings 화면에 "마지막 동기화: ..." 표시 (선택)

#### F4.4 Mac Catalyst / Native Mac 지원
- SwiftUI 기반이므로 Mac Catalyst 또는 "Designed for iPad" 모드 활용
- `regular` sizeClass 레이아웃이 이미 구현되어 있으므로 UI 추가 작업 최소
- Mac 전용 고려사항:
  - 키보드 단축키 (Space: 플립, 1-4: 등급 선택)
  - 메뉴바 통합 (선택)

---

### Phase 5: Polish & Enhancement (품질 향상)

#### F5.1 검색 및 필터
- Home: 덱 이름 검색
- DeckDetail: 카드 front/back 검색
- 필터: 전체 / 복습 예정 / 새 카드 / 학습중

#### F5.2 알림 (Notifications)
- 매일 복습 알림 (설정 가능한 시간)
- Overdue 카드 알림
- `UNUserNotificationCenter` 사용

#### F5.3 위젯 (WidgetKit)
- 오늘의 복습 예정 카드 수
- 연속 학습일 표시
- Lock Screen 위젯

#### F5.4 유닛 테스트
- **SRS 엔진 테스트**: 모든 등급 조합에 대한 interval/easeFactor 검증
- **CSV 파서 테스트**: 정상 CSV, 비정상 CSV, 빈 파일, BOM 처리
- **Interactor 테스트**: CRUD 동작 검증 (in-memory ModelContainer 사용)
- **Presenter 테스트**: viewState 매핑 검증
- 목표: 비즈니스 로직 커버리지 80%+

#### F5.5 온보딩
- 첫 실행 시 3단계 온보딩 (앱 소개, 샘플 덱 생성, 학습 방법 안내)
- 샘플 덱 "Getting Started" 자동 생성

#### F5.6 Settings 확장
- 일일 새 카드 한도 설정
- 세션 최대 카드 수 설정
- 복습 알림 시간 설정
- iCloud 동기화 ON/OFF
- 데이터 내보내기 (CSV Export)

---

## 5. Technical Architecture

### 5.1 Data Layer 변경

```
현재 (As-Is)                    →   목표 (To-Be)
──────────────────────────────       ──────────────────────────────
struct Deck (let, 불변)          →   @Model class Deck (SwiftData)
struct Card (let, 불변)          →   @Model class Card (SwiftData)
관계 없음                        →   Deck ↔ Card 1:N 관계
하드코딩 샘플 데이터              →   ModelContainer + ModelContext
없음                             →   @Model class StudyLog
없음                             →   CloudKit 자동 동기화
```

### 5.2 Interactor 변경

```swift
// 현재: 하드코딩 반환
class HomeInteractor {
    func fetchHomeData() -> HomeData {
        return HomeData(stats: HomeStats(streakDays: 12, ...), ...)
    }
}

// 목표: ModelContext 주입 + 실제 쿼리
class HomeInteractor {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchHomeData() -> HomeData {
        let descriptor = FetchDescriptor<Deck>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        let decks = try? modelContext.fetch(descriptor)
        // ... 실제 통계 계산
    }
}
```

### 5.3 의존성 주입 변경

```swift
// 현재: 의존성 없음
ContentView → HomeView(path:) → HomePresenter() → HomeInteractor()

// 목표: ModelContext 전달
KonitFlashApp(.modelContainer)
  → ContentView(@Environment(\.modelContext))
    → HomeView(path:, modelContext:)
      → HomePresenter(interactor: HomeInteractor(modelContext:))
```

### 5.4 CSV Import Architecture

```
FileImporter → Data(contentsOf:) → CSVParser.parse(data:)
                                        ↓
                                  CSVParseResult
                                  - cards: [(front, back)]
                                  - skippedRows: Int
                                  - errors: [String]
                                        ↓
                                  Preview UI (확인)
                                        ↓
                                  Interactor.importCards(into: Deck)
                                        ↓
                                  ModelContext.insert(Card...)
```

---

## 6. Development Phases & Milestones

### Phase 1: Data Foundation 🏗️
| 태스크 | 우선순위 | 복잡도 |
|--------|---------|--------|
| SwiftData 모델 정의 (Deck, Card, StudyLog) | P0 | Medium |
| ModelContainer 설정 (KonitFlashApp) | P0 | Low |
| Interactor에 ModelContext DI 적용 | P0 | Medium |
| HomeInteractor 실제 쿼리 구현 | P0 | Medium |
| DeckDetailInteractor 실제 쿼리 구현 | P0 | Medium |
| AddDeck/AddCard Interactor CRUD 구현 | P0 | Medium |
| Delete 영속화 (Deck, Card) | P0 | Low |
| Empty State UI 추가 | P1 | Low |
| 실제 통계 계산 (HomeStats, DayActivity) | P1 | Medium |
| 기존 struct → @Model 마이그레이션 | P0 | High |

### Phase 2: Spaced Repetition ⏱️
| 태스크 | 우선순위 | 복잡도 |
|--------|---------|--------|
| SM-2 알고리즘 엔진 구현 | P0 | High |
| FlashCardInteractor 학습 세션 쿼리 | P0 | Medium |
| recordAnswer() → Card 상태 업데이트 | P0 | Medium |
| StudyLog 기록 | P0 | Low |
| computeIntervals() 실제 계산 | P0 | Medium |
| Overdue 배너 "Catch Up Now" 연동 | P1 | Low |
| SRS 엔진 유닛 테스트 | P0 | Medium |

### Phase 3: CSV Import 📄
| 태스크 | 우선순위 | 복잡도 |
|--------|---------|--------|
| CSVParser 구현 | P0 | Medium |
| 임포트 UI (fileImporter + 미리보기) | P0 | Medium |
| DeckDetail "CSV 임포트" 버튼 추가 | P0 | Low |
| AddDeck "CSV에서 임포트" 플로우 | P1 | Medium |
| 중복 카드 감지 | P2 | Low |
| CSVParser 유닛 테스트 | P0 | Medium |

### Phase 4: iCloud Sync ☁️
| 태스크 | 우선순위 | 복잡도 |
|--------|---------|--------|
| iCloud 컨테이너 ID 설정 | P0 | Low |
| ModelConfiguration cloudKit 설정 | P0 | Low |
| SwiftData 모델 CloudKit 호환성 검증 | P0 | Medium |
| 충돌 해결 전략 구현 | P1 | High |
| Mac 타겟 추가 | P0 | Medium |
| 키보드 단축키 (Mac) | P2 | Low |

### Phase 5: Polish 🎨
| 태스크 | 우선순위 | 복잡도 |
|--------|---------|--------|
| 검색 기능 (덱/카드) | P1 | Medium |
| 복습 알림 (Notifications) | P2 | Medium |
| 위젯 (WidgetKit) | P2 | High |
| 유닛 테스트 스위트 확장 | P1 | High |
| 온보딩 플로우 | P2 | Medium |
| Settings 확장 (학습 설정) | P1 | Medium |
| CSV Export | P2 | Low |

---

## 7. Non-Functional Requirements

| 항목 | 요구사항 |
|------|---------|
| **성능** | 1000+ 카드 덱에서 학습 세션 로딩 < 1초 |
| **동기화** | iCloud 변경사항 5초 이내 반영 (네트워크 상태 의존) |
| **오프라인** | 네트워크 없이 모든 학습 기능 정상 동작 |
| **데이터 안전** | 앱 비정상 종료 시 학습 기록 유실 없음 (즉시 저장) |
| **접근성** | VoiceOver 지원, Dynamic Type 지원 |
| **최소 사양** | iOS 18.6+, macOS 15.0+ |
| **저장 용량** | 카드 1만 장 기준 < 50MB |

---

## 8. Risks & Mitigations

| 리스크 | 영향 | 완화 |
|--------|------|------|
| SwiftData CloudKit 동기화 제한 (unique 미지원) | 중복 데이터 발생 가능 | 앱 레벨 중복 검사 + updatedAt 기반 해결 |
| SM-2 알고리즘 사용자 경험 | 과도한 복습 → 이탈 | Easy/Hard 등급으로 사용자 피드백 반영, 일일 한도 설정 |
| NotebookLM CSV 포맷 변경 | 임포트 실패 | 유연한 파서 + 에러 리포팅 |
| struct → @Model 마이그레이션 | 대규모 코드 변경 | Phase 1에서 집중 처리, 점진적 전환 |
| iCloud 계정 미로그인 | 동기화 불가 | 로컬 전용 모드 안내 + Settings에서 상태 표시 |

---

## 9. Success Metrics

| 지표 | 목표 |
|------|------|
| 일일 학습 세션 수 | 사용자당 평균 2회+ |
| 7일 리텐션 | 60%+ |
| CSV 임포트 성공률 | 95%+ |
| iCloud 동기화 성공률 | 99%+ |
| Crash-free rate | 99.5%+ |

---

## 10. Glossary

| 용어 | 설명 |
|------|------|
| **SM-2** | SuperMemo 2 알고리즘. 카드 난이도와 반복 횟수에 따라 복습 간격을 계산하는 간격 반복 알고리즘 |
| **Ease Factor (EF)** | 카드 난이도 계수 (기본 2.5). 높을수록 복습 간격이 길어짐 |
| **Interval** | 다음 복습까지의 간격 (일 단위) |
| **Due Card** | 복습 예정일이 오늘 이전인 카드 |
| **New Card** | 한 번도 학습하지 않은 카드 (repetitions = 0) |
| **Leitner Box** | 카드의 학습 단계를 나타내는 상자 번호 (1-5). SM-2와 별개로 시각적 진행도 표시용 |
| **NotebookLM** | Google의 AI 기반 노트 도구. CSV로 학습 자료 내보내기 지원 |
