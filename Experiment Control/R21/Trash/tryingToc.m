function [] = tryingToc(s, doorFuns)

tOut = toc;

if tOut >= 10
    writeline(s,doorFuns.centralOpen)
end