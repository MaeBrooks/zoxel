pub const AirBlock = struct {};
pub const SolidBlock = struct { id: u8 };

pub const Block = union {
    air: AirBlock,
    solid: SolidBlock,
};

pub fn Chunk(comptime height_: u8, comptime width_: u8, comptime depth_: u8) type {
    return struct {
        const height = height_;
        const width = width_;
        const depth = depth_;
        const size = height * width * depth;
        const data: [size]Block = [size]AirBlock;
    };
}

pub fn VoxelEngine(comptime initial_chunks: u8, chunk_size: u8) type {
    return struct {
        var size: u64 = initial_chunks;
        var chunks: []Block = [initial_chunks]Chunk(
            chunk_size,
            chunk_size,
            chunk_size
        );
    };
}
