# KONIT Flash — App Store 유료 배포 TODO

> 유료 앱 (Paid App) 배포 기준 체크리스트
> 마지막 업데이트: 2026-03-20

---

## 1. Apple Developer 계정 & 계약

- [X] Apple Developer Program 등록 확인 (연간 $99, Team ID: H24UL983G7)
- [X] **유료 앱 계약 (Paid Applications Agreement)** 체결 — App Store Connect > Agreements, Tax, and Banking
- [X] 은행 계좌 등록 (수익 지급용)
- [X] 세금 정보 제출 (W-8BEN 또는 해당 국가 양식)

---

## 2. Xcode 프로젝트 설정

### 버전 & 빌드
- [X] `MARKETING_VERSION` 확정 (현재 `1.0`)
- [X] `CURRENT_PROJECT_VERSION` 확정 (현재 `1`)

### 배포 타겟
- [X] **프로젝트 레벨 Deployment Target 수정** — `26.2` → `18.6`으로 통일 완료
- [X] 타겟 레벨 Deployment Target 확인 (`18.6` — OK)

### 코드 서명
- [X] Automatic Signing 확인 (CODE_SIGN_STYLE = Automatic, Team: H24UL983G7)
- [X] Xcode가 Archive 시 자동으로 Distribution Certificate/Profile 처리

### Entitlements
- [X] `aps-environment` 제거 (Push 미사용 — 불필요한 권한 삭제)
- [X] `UIBackgroundModes: remote-notification` 제거 (Info.plist)
- [X] iCloud Container ID (`iCloud.geunil.KonitFlash`) 확인
- [X] App Group (`group.geunil.KonitFlash`) 메인 + 위젯 공유 확인
- [X] CloudKit Dashboard에서 Production 환경 배포 확인

---

## 3. Privacy & 컴플라이언스

### Privacy Manifest (필수)
- [X] `PrivacyInfo.xcprivacy` 파일 생성
- [X] 사용 중인 Required Reason API 선언:
  - [X] `NSPrivacyAccessedAPICategoryUserDefaults` (CA92.1 — 앱 자체 UserDefaults 접근)
  - [X] `NSPrivacyAccessedAPICategoryFileTimestamp` — 미사용, 선언 불필요
- [X] `NSPrivacyCollectedDataTypes` — 빈 배열 (수집 데이터 없음)
- [X] `NSPrivacyTracking` = `false`
- [X] `NSPrivacyTrackingDomains` = 빈 배열

### 개인정보 처리방침
- [X] 개인정보 처리방침 (Privacy Policy) 웹페이지 작성 (Notion, 4개 언어)
- [X] URL 확보 (Notion)
- [X] App Store Connect에 URL 등록

### 수출 규정
- [X] `ITSAppUsesNonExemptEncryption = false` 확인 (Info.plist — 설정 완료)

---

## 4. App Store Connect 설정

### 앱 등록
- [X] App Store Connect에서 새 앱 생성
  - Bundle ID: `geunil.KonitFlash`
  - SKU: `KonitFlash` (또는 원하는 값)
  - Primary Language: Korean 또는 English
- [X] 가격 설정 (유료 앱 가격 티어 선택)

### 메타데이터 입력 (AppStoreMetadata.md 기반)
- [X] 앱 이름: `KONIT Flash - Spaced Repetition`
- [X] 부제 — EN / KO / JA / ZH 각각 입력
- [X] 설명 — EN / KO / JA / ZH 각각 입력
- [X] 키워드 — EN / KO / JA / ZH 각각 입력
- [X] 프로모션 텍스트 — EN / KO / JA / ZH 각각 입력
- [X] 카테고리: Education (Primary) / Productivity (Secondary)
- [X] 연령 등급: 4+
- [X] 개인정보 처리방침 URL
- [X] 지원 URL (Support URL) — 블로그 URL 사용
- [X] 저작권 정보

### 가격 & 판매 지역
- [X] 가격 티어 선택 (예: Tier 1 = $0.99 / ₩1,500)
- [X] 판매 지역 선택 (전체 또는 특정 국가)
- [X] 사전 주문 설정 여부 결정

---

## 5. 앱 아이콘 & 스크린샷

### 앱 아이콘
- [X] 메인 앱 아이콘 1024×1024 확인 (이미 있음 — light/dark/tinted)
- [X] Widget 앱 아이콘 추가 완료 (메인 앱 아이콘과 동일)

### 스크린샷 제작
- [X] **6.7" iPhone** (iPhone 15/16 Pro Max) — 필수, 8장
  - [X] 1. Home (덱 목록)
  - [X] 2. FlashCard 앞면
  - [X] 3. FlashCard 뒷면 + 답변 버튼
  - [X] 4. 학습 결과 화면
  - [X] 5. DeckDetail
  - [X] 6. CSV Import 미리보기
  - [X] 7. Home (Mac 레이아웃)
  - [X] 8. Settings (다국어)
- [X] 각 스크린샷 4개 언어 캡션 적용 (EN / KO / JA / ZH)
- [X] Mac 스크린샷 (Mac 배포 시)
- [X] 샘플 데이터 준비 (덱 3~4개, 카드 15~30장, streak 7일+)

### App Preview 동영상 (선택)
- [X] 30초 이내 앱 프리뷰 영상 제작 여부 결정

---

## 7. 심사 제출 (App Review)

### 제출 전 체크
- [ ] 모든 메타데이터 입력 완료
- [ ] 스크린샷 업로드 완료
- [ ] 빌드 선택 완료
- [ ] 심사 메모 작성 (필요 시 — 앱 사용법, 테스트 계정 등)
- [ ] 광고 추적 (IDFA) 사용 여부 응답: `No`

### 심사 대응
- [ ] 심사 기간: 보통 24~48시간 (최대 7일)
- [ ] 리젝 시 사유 확인 후 수정 재제출

---

## 8. 출시 후

- [ ] 앱 출시 방식 선택: 심사 통과 즉시 출시 / 수동 출시 / 특정 날짜
- [ ] 출시 후 크래시 모니터링 (Xcode Organizer > Crashes)
- [ ] App Store 리뷰 모니터링 및 답변
- [ ] 버전 1.1 업데이트 계획 수립

---

## 진행 순서 요약

```
1. Developer 계정 & 유료 계약 확인
2. Xcode 프로젝트 수정 (Deployment Target, Privacy Manifest, Widget Icon)
3. Privacy Policy 웹페이지 작성
4. App Store Connect 앱 등록 + 메타데이터 입력
5. 스크린샷 제작 & 업로드
6. 최종 테스트 → TestFlight
7. Archive → 업로드 → 심사 제출
8. 출시!
```
