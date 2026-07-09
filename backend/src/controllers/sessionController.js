import prisma from '../lib/prisma.js';
import { generateUniqueCode, generateQuestionIndices } from '../lib/sessionCode.js';

const levelConfigs = {
    facil:   { levelName: 'Fácil',   totalQuestions: 5,  timePerQuestion: 30, lives: 5 },
    medio:   { levelName: 'Médio',   totalQuestions: 8,  timePerQuestion: 20, lives: 3 },
    dificil: { levelName: 'Difícil', totalQuestions: 12, timePerQuestion: 15, lives: 2 },
};

// POST /sessions
export async function createSession(req, res) {
    const { difficulty } = req.body;

    const config = levelConfigs[difficulty];
    if (!config) {
        return res.status(400).json({ error: 'Dificuldade inválida. Use: facil, medio ou dificil' });
    }

    const code = await generateUniqueCode();
    const questionIndices = generateQuestionIndices(difficulty, config.totalQuestions);

    const session = await prisma.session.create({
        data: {
            code,
            difficulty,
            questionIndices,
            ...config,
        },
    });

    res.status(201).json({
        sessionId: session.id,
        code: session.code,
        difficulty: session.difficulty,
        levelName: session.levelName,
        totalQuestions: session.totalQuestions,
        timePerQuestion: session.timePerQuestion,
        lives: session.lives,
    });
}

// GET /sessions/:code
export async function getSession(req, res) {
    const session = await prisma.session.findUnique({
        where: { code: req.params.code },
        include: { players: { select: { id: true, name: true, status: true } } },
    });

    if (!session) return res.status(404).json({ error: 'Sessão não encontrada' });
    if (session.status === 'ENDED') return res.status(400).json({ error: 'Sessão já encerrada' });

    res.json({
        sessionId: session.id,
        code: session.code,
        status: session.status,
        difficulty: session.difficulty,
        levelName: session.levelName,
        totalQuestions: session.totalQuestions,
        timePerQuestion: session.timePerQuestion,
        lives: session.lives,
        players: session.players,
    });
}

// POST /sessions/:code/join
export async function joinSession(req, res) {
    const { name } = req.body;

    if (!name || !name.trim()) {
        return res.status(400).json({ error: 'Nome é obrigatório' });
    }

    const session = await prisma.session.findUnique({
        where: { code: req.params.code },
    });

    if (!session) return res.status(404).json({ error: 'Sessão não encontrada' });
    if (session.status !== 'WAITING') {
        return res.status(400).json({ error: 'Sessão não está aguardando jogadores' });
    }

    const player = await prisma.player.create({
        data: {
            name: name.trim(),
            sessionId: session.id,
            livesLeft: session.lives,
        },
    }).catch(() => null);

    if (!player) {
        return res.status(409).json({ error: 'Nome já em uso nesta sessão' });
    }

    // Notifica todos na room que um novo jogador entrou
    req.io.to(session.code).emit('session:player_joined', {
        player: { id: player.id, name: player.name, status: player.status },
        totalPlayers: await prisma.player.count({ where: { sessionId: session.id } }),
    });

    res.status(201).json({
        playerId: player.id,
        name: player.name,
        sessionId: session.id,
        questionIndices: session.questionIndices,
        config: {
            levelName: session.levelName,
            totalQuestions: session.totalQuestions,
            timePerQuestion: session.timePerQuestion,
            lives: session.lives,
        },
    });
}

// POST /sessions/:code/start
export async function startSession(req, res) {
    const session = await prisma.session.findUnique({
        where: { code: req.params.code },
    });

    if (!session) return res.status(404).json({ error: 'Sessão não encontrada' });
    if (session.status !== 'WAITING') {
        return res.status(400).json({ error: 'Sessão não está em estado WAITING' });
    }

    const startedAt = new Date();
    await prisma.session.update({
        where: { id: session.id },
        data: { status: 'PLAYING', startedAt },
    });

    await prisma.player.updateMany({
        where: { sessionId: session.id },
        data: { status: 'PLAYING' },
    });

    req.io.to(session.code).emit('session:started', {
        startedAt,
        questionIndices: session.questionIndices,
    });

    res.json({ status: 'PLAYING', startedAt });
}

// GET /sessions/:code/ranking
export async function getSessionRanking(req, res) {
    const session = await prisma.session.findUnique({
        where: { code: req.params.code },
        include: {
            players: {
                orderBy: [{ score: 'desc' }, { finishedAt: 'asc' }],
            },
        },
    });

    if (!session) return res.status(404).json({ error: 'Sessão não encontrada' });

    const rankings = session.players.map((p, i) => ({
        position: i + 1,
        playerId: p.id,
        name: p.name,
        score: p.score,
        correctAnswers: p.correctAnswers,
        totalAnswered: p.totalAnswered,
        accuracy: p.totalAnswered > 0 ? Math.round((p.correctAnswers / p.totalAnswered) * 100) : 0,
        status: p.status,
    }));

    res.json({ sessionId: session.id, status: session.status, rankings });
}

// GET /sessions/:code/report
export async function getSessionReport(req, res) {
    const session = await prisma.session.findUnique({
        where: { code: req.params.code },
        include: {
            players: {
                include: { answers: true },
                orderBy: [{ score: 'desc' }],
            },
        },
    });

    if (!session) return res.status(404).json({ error: 'Sessão não encontrada' });

    const axes = ['pensamento-computacional', 'mundo-digital', 'cultura-digital'];

    const players = session.players.map(p => {
        const byCategory = Object.fromEntries(
            axes.map(axis => {
                const relevant = p.answers.filter(a => a.correctAxis === axis);
                return [axis, {
                    correct: relevant.filter(a => a.isCorrect).length,
                    total: relevant.length,
                }];
            })
        );

        return {
            name: p.name,
            score: p.score,
            accuracy: p.totalAnswered > 0 ? Math.round((p.correctAnswers / p.totalAnswered) * 100) : 0,
            byCategory,
        };
    });

    // Média da turma por eixo
    const classAvgByCategory = Object.fromEntries(
        axes.map(axis => {
            const totals = players.reduce(
                (acc, p) => ({
                    correct: acc.correct + p.byCategory[axis].correct,
                    total: acc.total + p.byCategory[axis].total,
                }),
                { correct: 0, total: 0 }
            );
            return [axis, totals];
        })
    );

    const totalScore = players.reduce((s, p) => s + p.score, 0);
    const totalAccuracy = players.reduce((s, p) => s + p.accuracy, 0);

    res.json({
        sessionId: session.id,
        code: session.code,
        levelName: session.levelName,
        totalPlayers: players.length,
        players,
        classAverage: {
            score: players.length ? Math.round(totalScore / players.length) : 0,
            accuracy: players.length ? Math.round(totalAccuracy / players.length) : 0,
            byCategory: classAvgByCategory,
        },
    });
}

// POST /sessions/:code/end
export async function endSession(req, res) {
    const session = await prisma.session.findUnique({
        where: { code: req.params.code },
    });

    if (!session) return res.status(404).json({ error: 'Sessão não encontrada' });
    if (session.status === 'ENDED') return res.status(400).json({ error: 'Sessão já encerrada' });

    const endedAt = new Date();
    await prisma.session.update({
        where: { id: session.id },
        data: { status: 'ENDED', endedAt },
    });

    req.io.to(session.code).emit('session:ended', { endedAt });

    res.json({ status: 'ENDED', endedAt });
}
