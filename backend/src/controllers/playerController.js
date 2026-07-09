import prisma from '../lib/prisma.js';

// POST /players/:playerId/finish
export async function finishPlayer(req, res) {
    const { playerId } = req.params;
    const { score, livesLeft, correctAnswers, totalAnswered, answers } = req.body;

    const player = await prisma.player.findUnique({
        where: { id: playerId },
        include: { session: true },
    });

    if (!player) return res.status(404).json({ error: 'Jogador não encontrado' });
    if (player.status === 'FINISHED') return res.status(400).json({ error: 'Jogador já finalizou' });

    const finishedAt = new Date();

    await prisma.player.update({
        where: { id: playerId },
        data: {
            status: 'FINISHED',
            score,
            livesLeft,
            correctAnswers,
            totalAnswered,
            finishedAt,
            answers: {
                create: answers.map(a => ({
                    questionIndex: a.questionIndex,
                    chosenAxis: a.chosenAxis,
                    correctAxis: a.correctAxis,
                    isCorrect: a.isCorrect,
                    timeSpent: a.timeSpent,
                })),
            },
        },
    });

    const session = player.session;

    // Monta ranking atualizado
    const allPlayers = await prisma.player.findMany({
        where: { sessionId: session.id },
        orderBy: [{ score: 'desc' }, { finishedAt: 'asc' }],
    });

    const rankings = allPlayers.map((p, i) => ({
        position: i + 1,
        playerId: p.id,
        name: p.name,
        score: p.score,
        correctAnswers: p.correctAnswers,
        totalAnswered: p.totalAnswered,
        accuracy: p.totalAnswered > 0 ? Math.round((p.correctAnswers / p.totalAnswered) * 100) : 0,
        status: p.status,
    }));

    // Emite para todos na room
    req.io.to(session.code).emit('session:player_finished', {
        playerId,
        name: player.name,
        score,
        correctAnswers,
        totalAnswered,
        accuracy: totalAnswered > 0 ? Math.round((correctAnswers / totalAnswered) * 100) : 0,
        position: rankings.findIndex(r => r.playerId === playerId) + 1,
    });

    req.io.to(session.code).emit('session:ranking_updated', { rankings });

    // Verifica se todos terminaram
    const allFinished = allPlayers.every(p => p.id === playerId ? true : p.status === 'FINISHED');

    if (allFinished) {
        await prisma.session.update({
            where: { id: session.id },
            data: { status: 'ENDED', endedAt: new Date() },
        });
        req.io.to(session.code).emit('session:all_finished', { rankings });
    }

    res.json({ ok: true, allFinished });
}
