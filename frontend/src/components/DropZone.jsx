import { useState } from 'react';

export default function DropZone({ axis, label, onDrop }) {
    const [isDragOver, setIsDragOver] = useState(false);

    return (
        <div
            className={`drop-zone drop-zone--${axis}${isDragOver ? ' drag-over' : ''}`}
            data-axis={axis}
            onDragOver={e => { e.preventDefault(); setIsDragOver(true); }}
            onDragLeave={() => setIsDragOver(false)}
            onDrop={() => { setIsDragOver(false); onDrop(axis); }}
        >
            {label}
        </div>
    );
}
