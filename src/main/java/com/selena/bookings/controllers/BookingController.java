package com.selena.bookings.controllers;

import com.selena.bookings.models.Booking;
import com.selena.bookings.services.BookingService;

import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;

import org.slf4j.Logger;

@RestController
@RequestMapping("/api/bookings")
public class BookingController {

    @Autowired
    private JdbcTemplate jdbcTemplate;
    private final BookingService bookingService;
    private final Logger logger = LoggerFactory.getLogger(BookingController.class);

    @Value("${spring.datasource.url}")
    private String dbUrl;

    @Value("${spring.datasource.username}")
    private String dbUser;

    @Value("${spring.datasource.password}")
    private String dbPass;

    public BookingController(BookingService bookingService, JdbcTemplate jdbcTemplate) {
        this.bookingService = bookingService;
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping("/test")
    public String test() {
        return "Booking service is running!s1234";
    }

    @GetMapping("/health/db")
    public String checkDatabaseConnection() {
        logger.info("🔍 Проверка подключения к БД...");
        logger.info("🔗 URL: {}", dbUrl);
        logger.info("👤 Username: {}", dbUser);
        logger.info("👤 Password: {}", dbPass);

        try {
            jdbcTemplate.queryForObject("SELECT 1", Integer.class);
            return "✅ Database connection is OK";
        } catch (Exception e) {
            e.printStackTrace();  // для дебага
            return "❌ Database connection failed: " + e.getMessage();
        }
    }

    @GetMapping
    public List<Booking> getAllBookings() {
        return bookingService.findAll();
    }

    @GetMapping("/{id}")
    public Booking getBooking(@PathVariable Long id) {
        return bookingService.findById(id)
                .orElseThrow(() -> new RuntimeException("Booking not found"));
    }

    @PostMapping
    public Booking createBooking(@RequestBody Booking booking) {
        return bookingService.save(booking);
    }

    @PutMapping("/{id}")
    public Booking updateBooking(@PathVariable Long id, @RequestBody Booking booking) {
        booking.setId(id);
        return bookingService.save(booking);
    }

    @DeleteMapping("/{id}")
    public void deleteBooking(@PathVariable Long id) {
        bookingService.deleteById(id);
    }
}