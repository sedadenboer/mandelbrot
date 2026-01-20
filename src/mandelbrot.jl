using Images, ColorTypes, Base.Threads
using ImageIO

"""
    mandelbrot(c, max_iter)

Compute the number of iterations (escape count) until the Mandelbrot sequence 
`z = z^2 + c` diverges or until `max_iter` is reached. Returns the iteration count.

# Arguments
- `c::Complex`: The complex point to test.
- `max_iter::Int`: Maximum number of iterations.

# Returns
- `Int`: Number of iterations before divergence (or `max_iter` if bounded).
"""
function mandelbrot(c, max_iter)
    z = 0.0 + 0.0im
    iter = 0
    while abs(z) <= 2.0 && iter < max_iter
        z = z^2 + c
        iter += 1
    end
    return iter
end

"""
    normalize(iter, max_iter)

Normalize the escape count to a value between 0.0 and 1.0 for coloring purposes.

# Arguments
- `iter::Int`: Iteration count returned by `mandelbrot`.
- `max_iter::Int`: Maximum iterations.

# Returns
- `Float64`: Normalized escape value (0.0 for points inside the set).
"""
normalize(iter, max_iter) = iter == max_iter ? 0.0 : iter / max_iter

"""
    escape_count_to_color(iter, max_iter)

Convert the normalized escape count to an RGB color.

# Arguments
- `iter::Int`: Iteration count.
- `max_iter::Int`: Maximum iterations.

# Returns
- `RGB{N0f8}`: Color for the pixel.
"""
escape_count_to_color(iter, max_iter) = RGB{N0f8}(normalize(iter, max_iter),
                                            normalize(iter, max_iter),
                                            normalize(iter, max_iter))

"""
    render_mandelbrot(x_min, x_max, y_min, y_max, width, height, max_iter)

Render a Mandelbrot set image for the given complex plane bounds and resolution.

# Arguments
- `x_min, x_max::Float64`: Horizontal bounds in the complex plane.
- `y_min, y_max::Float64`: Vertical bounds in the complex plane.
- `width, height::Int`: Image resolution in pixels.
- `max_iter::Int`: Maximum iterations per pixel.

# Returns
- `Array{RGB{N0f8},2}`: 2D array of RGB colors representing the Mandelbrot set.
"""
function render_mandelbrot(x_min, x_max, y_min, y_max, width, height, max_iter)
    img = Array{RGB{N0f8}}(undef, height, width)

    @threads for y in 1:height
        # Complex y-coordinate
        cy = y_min + (y-1)/(height-1) * (y_max - y_min)

        for x in 1:width
            # Complex x-coordinate
            cx = x_min + (x-1)/(width-1) * (x_max - x_min)

            escape_count = mandelbrot(cx + cy*im, max_iter)
            img[y, x] = escape_count_to_color(escape_count, max_iter)
        end
    end

    return img
end

"""
    save_mandelbrot_image(path; width=800, height=600, max_iter=300,
                          pixel_density=1.0, dpi=300)

Generate and save a Mandelbrot image with adjustable pixel density and DPI.

# Keyword Arguments
- `width, height`: base image size
- `max_iter`: maximum iterations per pixel
- `pixel_density`: scale factor for higher resolution (e.g., 2.0 = 2× width & height)
- `dpi`: dots per inch metadata for image export
"""
function save_mandelbrot_image(path; width=800, height=600, max_iter=300,
                               pixel_density=1.0, dpi=300)                     
    # Scale image by pixel_density
    scaled_width = Int(width * pixel_density)
    scaled_height = Int(height * pixel_density)

    x_min, x_max = -2.0, 1.0
    y_min, y_max = -1.2, 1.2

    img = render_mandelbrot(x_min, x_max, y_min, y_max, scaled_width, scaled_height, max_iter)
    save(path, img; dpi=(dpi,dpi))
end


save_mandelbrot_image("../figures/mandelbrot.png"; width=800, height=600,
                      max_iter=100, pixel_density=2.0, dpi=300)