collisions = {}

function collisions.checkCollision(a, b)
    return a.x < b.x + b.w and
            b.x < a.x + a.w and
            a.y < b.y + b.h and
            b.y < a.y + a.h
end

function collisions.circleCollision(ax, ay, ar, bx, by, br)

end

return collisions