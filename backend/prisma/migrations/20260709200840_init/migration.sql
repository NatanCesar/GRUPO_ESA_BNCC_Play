-- CreateEnum
CREATE TYPE "SessionStatus" AS ENUM ('WAITING', 'PLAYING', 'ENDED');

-- CreateEnum
CREATE TYPE "PlayerStatus" AS ENUM ('WAITING', 'PLAYING', 'FINISHED');

-- CreateTable
CREATE TABLE "Session" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "status" "SessionStatus" NOT NULL DEFAULT 'WAITING',
    "difficulty" TEXT NOT NULL,
    "totalQuestions" INTEGER NOT NULL,
    "timePerQuestion" INTEGER NOT NULL,
    "lives" INTEGER NOT NULL,
    "levelName" TEXT NOT NULL,
    "questionIndices" INTEGER[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "startedAt" TIMESTAMP(3),
    "endedAt" TIMESTAMP(3),

    CONSTRAINT "Session_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Player" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "status" "PlayerStatus" NOT NULL DEFAULT 'WAITING',
    "score" INTEGER NOT NULL DEFAULT 0,
    "livesLeft" INTEGER NOT NULL,
    "correctAnswers" INTEGER NOT NULL DEFAULT 0,
    "totalAnswered" INTEGER NOT NULL DEFAULT 0,
    "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "finishedAt" TIMESTAMP(3),
    "sessionId" TEXT NOT NULL,

    CONSTRAINT "Player_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Answer" (
    "id" TEXT NOT NULL,
    "questionIndex" INTEGER NOT NULL,
    "chosenAxis" TEXT NOT NULL,
    "correctAxis" TEXT NOT NULL,
    "isCorrect" BOOLEAN NOT NULL,
    "timeSpent" INTEGER NOT NULL,
    "answeredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "playerId" TEXT NOT NULL,

    CONSTRAINT "Answer_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Session_code_key" ON "Session"("code");

-- CreateIndex
CREATE UNIQUE INDEX "Player_sessionId_name_key" ON "Player"("sessionId", "name");

-- AddForeignKey
ALTER TABLE "Player" ADD CONSTRAINT "Player_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "Session"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Answer" ADD CONSTRAINT "Answer_playerId_fkey" FOREIGN KEY ("playerId") REFERENCES "Player"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

