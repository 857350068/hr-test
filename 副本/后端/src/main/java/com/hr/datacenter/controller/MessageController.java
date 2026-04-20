package com.hr.datacenter.controller;

import com.hr.datacenter.common.Result;
import com.hr.datacenter.entity.Message;
import com.hr.datacenter.service.MessageService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 消息通知控制器
 *
 * @author HR DataCenter Team
 * @since 2024-01-20
 */
@Slf4j
@RestController
@RequestMapping("/message")
@CrossOrigin(origins = "*")
public class MessageController {

    @Autowired
    private MessageService messageService;

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    /**
     * 发送系统公告（广播）
     */
    @PostMapping("/broadcast")
    public Result<String> broadcast(@RequestBody Message message) {
        try {
            messageService.saveMessage(message);
            // 广播消息给所有用户
            messagingTemplate.convertAndSend("/topic/broadcast", message);
            log.info("发送系统公告: {}", message.getTitle());
            return Result.success("发送成功");
        } catch (Exception e) {
            log.error("发送系统公告失败", e);
            return Result.error("发送失败: " + e.getMessage());
        }
    }

    /**
     * 发送个人消息
     */
    @PostMapping("/send")
    public Result<String> sendMessage(@RequestBody Message message) {
        try {
            messageService.saveMessage(message);
            // 发送消息给指定用户
            messagingTemplate.convertAndSendToUser(
                    message.getReceiverId().toString(),
                    "/queue/message",
                    message
            );
            log.info("发送个人消息: from={}, to={}", message.getSenderId(), message.getReceiverId());
            return Result.success("发送成功");
        } catch (Exception e) {
            log.error("发送消息失败", e);
            return Result.error("发送失败: " + e.getMessage());
        }
    }

    /**
     * 获取用户消息列表
     */
    @GetMapping("/list")
    public Result<List<Message>> getMessageList(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int size) {
        List<Message> messages = messageService.getMessageList(userId, page, size);
        return Result.success(messages);
    }

    /**
     * 获取未读消息数量
     */
    @GetMapping("/unread-count")
    public Result<Integer> getUnreadCount(@RequestParam Long userId) {
        int count = messageService.getUnreadCount(userId);
        return Result.success(count);
    }

    /**
     * 标记消息为已读
     */
    @PutMapping("/read/{messageId}")
    public Result<String> markAsRead(@PathVariable Long messageId) {
        boolean success = messageService.markAsRead(messageId);
        if (success) {
            return Result.success("标记成功");
        }
        return Result.error("标记失败");
    }

    /**
     * 批量标记为已读
     */
    @PutMapping("/read-all")
    public Result<String> markAllAsRead(@RequestParam Long userId) {
        boolean success = messageService.markAllAsRead(userId);
        if (success) {
            return Result.success("标记成功");
        }
        return Result.error("标记失败");
    }

    /**
     * 删除消息
     */
    @DeleteMapping("/delete/{messageId}")
    public Result<String> deleteMessage(@PathVariable Long messageId) {
        boolean success = messageService.deleteMessage(messageId);
        if (success) {
            return Result.success("删除成功");
        }
        return Result.error("删除失败");
    }

    /**
     * WebSocket消息处理 - 广播
     */
    @MessageMapping("/broadcast")
    @SendTo("/topic/broadcast")
    public Message handleBroadcast(Message message) {
        log.info("收到广播消息: {}", message.getContent());
        return message;
    }

    /**
     * WebSocket消息处理 - 私聊
     */
    @MessageMapping("/private")
    public void handlePrivateMessage(Message message) {
        log.info("收到私聊消息: from={}, to={}", message.getSenderId(), message.getReceiverId());
        messagingTemplate.convertAndSendToUser(
                message.getReceiverId().toString(),
                "/queue/message",
                message
        );
    }

    /**
     * 发送审批提醒
     */
    @PostMapping("/approval-reminder")
    public Result<String> sendApprovalReminder(@RequestBody Map<String, Object> params) {
        try {
            Long approvalId = Long.valueOf(params.get("approvalId").toString());
            Long userId = Long.valueOf(params.get("userId").toString());
            String title = params.get("title").toString();
            String content = params.get("content").toString();

            Message message = new Message();
            message.setReceiverId(userId);
            message.setTitle(title);
            message.setContent(content);
            message.setMessageType(2); // 审批提醒
            message.setRelatedId(approvalId);

            messageService.saveMessage(message);
            messagingTemplate.convertAndSendToUser(
                    userId.toString(),
                    "/queue/approval",
                    message
            );

            log.info("发送审批提醒: userId={}, approvalId={}", userId, approvalId);
            return Result.success("发送成功");
        } catch (Exception e) {
            log.error("发送审批提醒失败", e);
            return Result.error("发送失败: " + e.getMessage());
        }
    }
}
