namespace "queue" do
  desc "print out contents of checkpoint file (specify path)"
  task "print-checkpoint", [:ckpfile] do |t, args|
    bin = IO.read(args.ckpfile, mode: "rb")
      # + Short.BYTES    // version 16 bits
      # + Integer.BYTES  // pageNum 32 bits
      # + Integer.BYTES  // firstUnackedPageNum 32 bits
      # + Long.BYTES     // firstUnackedSeqNum 64 bits
      # + Long.BYTES     // minSeqNum 64 bits
      # + Integer.BYTES  // eventCount  32 bits
      # + Integer.BYTES; // checksum 32 bits
    ints = []
    i = 0
    [[2, "n"], [4, "N"], [4, "N"], [4, "N"], [4, "N"], [4, "N"], [4, "N"], [4, "N"], [4, "N"]].each do |pos, unp|
      ints << bin[i, pos].unpack(unp).first
      i = i + pos
    end
    hiusn = ints[3] << 32
    hisn = ints[5] << 32
    puts("version: #{ints[0]}, pageNum: #{ints[1]}, firstUnackedPageNum: #{ints[2]}, firstUnackedSeqNum: #{hiusn + ints[4]}, minSeqNum: #{hisn + ints[6]}, eventCount: #{ints[7]}, checksum: #{ints[8]}.")
  end
end
