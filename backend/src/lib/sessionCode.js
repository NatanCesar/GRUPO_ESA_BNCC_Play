import prisma from './prisma.js';

const LETTERS = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // sem I e O para evitar confusão visual
const DIGITS = '0123456789';

// Pools cumulativos por dificuldade — blocos de índice em frontend/src/data/questions.js
// (0-9 fácil, 10-19 médio, 20-29 difícil)
const POOL_SIZES = { facil: 10, medio: 20, dificil: 30 };

function generateCode() {
    const l = () => LETTERS[Math.floor(Math.random() * LETTERS.length)];
    const d = () => DIGITS[Math.floor(Math.random() * DIGITS.length)];
    return `${l()}${l()}${l()}-${d()}${d()}${d()}`;
}

export async function generateUniqueCode() {
    for (let i = 0; i < 10; i++) {
        const code = generateCode();
        const exists = await prisma.session.findUnique({ where: { code } });
        if (!exists) return code;
    }
    throw new Error('Não foi possível gerar código único');
}

export function generateQuestionIndices(difficulty, totalQuestions) {
    const poolSize = POOL_SIZES[difficulty] ?? POOL_SIZES.dificil;
    const all = Array.from({ length: poolSize }, (_, i) => i);
    for (let i = all.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [all[i], all[j]] = [all[j], all[i]];
    }
    return all.slice(0, totalQuestions);
}
