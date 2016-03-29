require 'gnuplot'
require 'os'
require 'paths'
require 'torch'

local tester = torch.Tester()
local tests = {}

-- Returns a random string of lowercase digits
local function randomFilenameStr()
   local t = {}
   for i = 1, 10 do
      table.insert(t, string.char(math.random(97, 122)))
   end
   return table.concat(t)
end

-- Make sure we can write to a new filename, but not to a nonexistent directory.
function tests.cannotWriteToNonExistentDir()
   -- Save locally, this should work
   local validFilename = randomFilenameStr() .. '.png'

   -- If this already exists (bad luck!), don't let the test overwrite it
   assert(not (paths.filep(validFilename) or
               paths.dirp(validFilename)),
          'random filename aready exists (?)')

   -- Should work fine
   gnuplot.pngfigure(validFilename)
   gnuplot.plot({'Sin Curve',torch.sin(torch.linspace(-5,5))})
   gnuplot.plotflush()

   -- Clean up after ourselves
   os.remove(validFilename)

   -- Now make an invalid output
   local nonExistentDir = randomFilenameStr()
   assert(not (paths.filep(nonExistentDir) or
               paths.dirp(nonExistentDir)),
          'random dir aready exists (?)')

   -- This makes an absolute path below cwd, seems Lua has no way (?) to query
   -- the file separator charater by itself...
   local invalidFilename = paths.concat(nonExistentDir, validFilename)
   local function shouldCrash()
      gnuplot.pngfigure(invalidFilename)
   end
   tester:assertErrorPattern(shouldCrash, 'directory does not exist')
end

tester:add(tests)
return tester:run()
